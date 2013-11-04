HTTP Proxy Caching
******************

.. Licensed to the Apache Software Foundation (ASF) under one
   or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.

Web proxy caching enables you to store copies of frequently-accessed web
objects (such as documents, images, and articles) and then serve this
information to users on demand. It improves performance and frees up
Internet bandwidth for other tasks.

This chapter discusses the following topics:

.. toctree::
   :maxdepth: 2

Understanding HTTP Web Proxy Caching
====================================

インターネットユーザはインターネット上のウェブサーバーへリクエストを出します。
キャッシュサーバーはこれらのリクエストを満たすために **ウェブプロキシサーバー** として
振る舞わなくてはなりません。
ウェブプロキシーサーバーがウェブオブジェクトへのリクエストを受け取った後は、
そのリクエストを返すか、**オリジンサーバー** (リクエストされた情報のオリジナルコピーを
持っているウェブサーバー)へ転送します。Traffic Server proxy は **explicit proxy caching** を
サポートしています。この際、 ユーザーのクライアントソフトが Traffic Server proxy へ
直接リクエストを送るように設定されている必要があります。
次のオーバービューは Traffic Server がどのようにリクエストを返すかを描いています。

1. Traffic Server がウェブオブジェクトへのクライアントリクエストを受け取ります。

2. オブジェクトのアドレスを用いて、Traffic Server はオブジェクトデータベース( **キャッシュ** )
   にリクエストされたオブジェクトを探します。

3. キャッシュにオブジェクトがある場合、Traffic Server はオブジェクトが提供するのに
   十分新しいか確認します。
   新しい場合、Traffic Server は *キャッシュヒット* (後述) としてクライアントにそれを
   提供します。

   .. figure:: ../static/images/admin/cache_hit.jpg
      :align: center
      :alt: A cache hit

      A cache hit
4. キャッシュのデータが古い場合、Traffic Server はオリジンサーバーへ接続し、
   オブジェクトが依然新しいかどうか確認します。( **再確認** )
   新しい場合、Traffic Server はすぐにキャッシュしているコピーをクライアントに
   送ります。

5. オブジェクトがキャッシュに無い場合 (**キャッシュミス**) やサーバーがキャッシュした
   コピーをもはや有効ではないと判断した場合、
   Traffic Server はオリジンサーバーからオブジェクトを取得します。
   オベジェクトは一度クライアントに流され、 Traffic Server キャッシュに配置します。
   (下の図を見てください) 続いて起こるオブジェクトへのリクエストはよりはやく
   提供することができます。それはオブジェクトがキャッシュから直接検索されるからです。

   .. figure:: ../static/images/admin/cache_miss.jpg
      :align: center
      :alt: A cache miss

      A cache miss

一般的にキャッシュは前述の概要で説明したものよりも複雑です。
詳しく述べると、概要では Traffic Server がどのように新しさを保証し、
正しい HTTP alternates を提供し、キャッシュできない/するべきではないオブジェクトへの
リクエストを扱うかについて説明されていませんでした。
次の章はこれらのことについてとても詳しく説明します。

Ensuring Cached Object Freshness
================================

Traffic Server がウェブオブジェクトへのリクエストを受け取った際、
最初にリクエストされたオブジェクトをキャッシュに入れようとします。
オブジェクトがキャッシュにある場合、Traffic Server はオブジェクトが提供するのに
十分新しいかどうかを確認します。
Traffic Server は HTTP オブジェクトに作成者が指定した有効期限をサポートしています。
Traffic Server はこれらの有効期限を固く守ります。つまり、どれだけ頻繁にオブジェクトが
変更されるかと、管理者が選んだフレッシュネスガイドラインに基づいて、有効期限を選択します。
オブジェクトはまた、依然として新しいかどうかをオリジンサーバーへ
見に行くことにより、再確認されます。

HTTP Object Freshness
---------------------

Traffic Server はキャッシュした HTTP オブジェクトが新しいかどうかを
次のことによって決定します。

-  **Checking the ``Expires`` or ``max-age`` header**

   いくつかの HTTP オブジェクトは ``Expire`` ヘッダーや ``max-age`` ヘッダーを含んでいます。
   これらはオブジェクトがどれくらいの期間キャッシュできるかどうかを明確に定義しています。
   Traffic Server はオブジェクトが新鮮であるかどうかを決定するために、
   現在時刻と有効期限を比較します。

-  **Checking the ``Last-Modified`` / ``Date`` header**

   HTTP オブジェクトが ``Expire`` ヘッダーや ``max-age`` ヘッダーを持っていない場合、
   Traffic Server はフレッシュネスリミットを
   次の式で計算します。

       freshness_limit = ( date - last_modified ) * 0.10

   この *date* はオブジェクトのサーバーのレスポンスヘッダーの日付で、*last_modified* は
   ``Last-Modified`` ヘッダーの日付です。
   ``Last-Modified`` ヘッダーが無い場合、Traffic Server はオブジェクトがキャッシュに
   書かれた日時を使用します。
   ``0.10`` (10 %) という値は必要に応じて、増減することができます。
   (詳しくは `Modifying the Aging Factor for Freshness Computations <#ModifyingAgingFactorFreshnessComputations>`_　を参照してください)

   計算されたフレッシュネスリミットは最小値と最大値に紐づけられます。
   - 詳細は `Setting an Absolute Freshness Limit`_ を参照してください。

-  **Checking the absolute freshness limit**

   ``Expires`` ヘッダー等を持っていない、もしくは ``Last-Modified`` と ``Date`` ヘッダーの両方を
   もっていないHTTP オブジェクトについて、Traffic Server は最小で最大のフレッシュネスリミットを
   使用します。( `Setting an Absolute Freshness Limit`_ を参照してください。)

-  **Checking revalidate rules in the `cache.config`_ file**

   再確認ルールは特定の HTTP オブジェクトにフレッシュネスリミットを適用します。
   特定のドメインや IP アドレスから来たオブジェクト、特定の正規表現を含む URL を持つ
   オブジェクトや特定のクライアントからリクエストされたオブジェクトなどに
   フレッシュネスリミットを設定することができます。( `cache.config`_ を参照してください。)

Modifying Aging Factor for Freshness Computations
-------------------------------------------------

オブジェクトが有効期限に関する情報を持っていない場合、Traffic Server は
 ``Last-Modified`` と ``Date`` ヘッダーから新鮮さを見積もります。
デフォルトでは Traffic Server は最後に更新されてからの経過時間の 10 %
キャッシュします。
必要に応じて、増減することができます。

新鮮さの計算のための期間の要素を変更するためには、

1. `records.config`_ の次の値を変更してください。

   -  `proxy.config.http.cache.heuristic_lm_factor`_

2. 設定の変更を適用するための ``traffic_line -x`` コマンド
   を実行してください。

Setting absolute Freshness Limits
---------------------------------

いくつかのオブジェクトは ``Expires`` ヘッダーを持っていない、
もしくは ``Last-Modified`` と ``Date`` ヘッダーの両方を持っていないことがあります。
これらのオブジェクトがキャッシュされてどの程度フレッシュであると考えられるか
制御するために、**absolute freshness limit** があります。

フレッシュネスリミットの絶対値を明確にするために

1. `records.config`_ の次の値を変更してください。

   -  `proxy.config.http.cache.heuristic_min_lifetime`_
   -  `proxy.config.http.cache.heuristic_max_lifetime`_

2. 設定の変更を適用するための ``traffic_line -x`` コマンド
   を実行してください。

Specifying Header Requirements
------------------------------

よりいっそうキャッシュしているオブジェクトの新鮮さを確かめるために、
特定のヘッダーを持っているオブジェクトだけをキャッシュするように
Traffic Server を設定することもできます。デフォルトでは Traffic Server
は (ヘッダーがないものも含む) 全てのオブジェクトをキャッシュします。
特別なプロキシーの状況の場合のみデフォルト設定を変更するべきです。
Traffic Server を ``Expires`` もしくは ``max-age`` ヘッダーを持つオブ
ジェクトだけをキャッシュするように設定した場合、キャッシュヒット率は
明らかに下がるでしょう。(とても少ないオブジェクトしか明確な有効期限の情報をもって
いないと考えられるためです。)

特定のヘッダーを持つオブジェクトをキャッシュするように Traffic Server を設定するには

1. `records.config`_ の次の変数を変更してください。

   -  `proxy.config.http.cache.required_headers`_

2. ``traffic_line -x`` コマンドを実行して、変更した設定を反映させてください。

Cache-Control Headers
---------------------

キャッシュしたあるオブジェクトが新鮮だと思われる場合であっても、クライ
アントやサーバーはキャッシュからのオブジェクトの復旧を妨害するようにた
びたび制限を課します。例えば、あるクライアントがキャッシュから復旧する
べき *ではない* オブジェクトへリクエストするかもしれません。
また、それをした場合、10 分以上はキャッシュすることはできません。
Traffic Server はキャッシュしたオブジェクトの提供可能性をクライアントの
リクエストとサーバーのレスポンス両方に現れる ``Cache-Control`` ヘッダー
を根拠に決定しています。

次のような ``Cache-Control`` ヘッダーはキャッシュからオブジェクトを提供するかどうかに影響します。

-  クライアントから送られる ``no-cache`` ヘッダーはどんなオブジェクトも
   キャッシュから直接返すべきではないということをTraffic Server に示します。
   従って、Traffic Server は常にオリジンサーバーからオブジェクトを取得します。
   Traffic Server をクライアントからの ``no-cache`` ヘッダーを無視するように
   設定することもできます。詳細は `Configuring Traffic Server to Ignore Client no-cache Headers`_
   を参照してください。

-  サーバーから送られる ``max-age`` ヘッダーはオブジェクトのキャッシュされて
   いる時間と比較されます。この時間が ``max-age`` よりも少ない場合、オブジェクトは
   フレッシュであり配信されます。

-  クライアントからの ``min-fresh`` ヘッダーは **受け入れることが許容できる新鮮さ** です。
   これはクライアントが少なくとも指定された程度新鮮であることを望ん
   でいるということを意味します。キャッシュされたオブジェクトが指定された
   長さを残さなくなった場合、再取得されます。

- クライアントからの ``max-stale`` ヘッダーは Traffic Server に古すぎな
  い失効したオブジェクトを配信することを許可します。いくつかのブラウザー
  は特に貧弱な Internet 環境にあるような場合パフォーマンスを向上させる
  ため、わずかに失効したオブジェクトを受け取ることを望むかもしれません。

Traffic Server は ``Cache-Control`` を HTTP の新鮮さの基準の *** 後に*** 配信可
能性の基準に適用します。例えば、あるオブジェクトが新鮮だと考えられる場合でも、経
過時間が ``max-age`` よりも大きいければ、それは配信されません。

Revalidating HTTP Objects
-------------------------

クライアントがキャッシュの中で新鮮ではなくなった HTTP オブジェクトをリ
クエストした際、Traffic Server はそのオブジェクトを再検証します。**再
検証** はオリジンサーバーへオブジェクトが変更されているかどうかを確認
する問い合わせです。再検証の結果は次のいずれかです。

-  オブジェクトが依然として新鮮な場合、Traffic Server はフレッシュネス
   リミットをリセットして、そのオブジェクトを配信します。

-  オブジェクトの新しいコピーが有効な場合、Traffic Server は新しいオブジェクトを
   キャッシュします。(従って、新鮮ではないコピーは置き換えられます)
   また、同時にオブジェクトをクライアントに配信します。

-  オブジェクトがオリジンサーバー上に存在しない場合、Traffic Server は
   キャッシュしたコピーを配信しません。

-  オリジンサーバーが再検証の問い合わせに応答しない場合、Traffic Server は
   ``111 Revalidation Failed`` 警告と共に新鮮ではないオブジェクトを配信します。

デフォルトでは Traffic Server はリクエストされた HTTP オブジェクトが新鮮ではない
と考えられる場合に再検証します。Traffic Server のオブジェクトの新鮮さの評価につ
いては `HTTP Object Freshness`_ で述べられています。次のオプションの一つを選ぶこ
とによって、 Traffic Server が新鮮さを評価する方法を再設定することができます。

-  Traffic Server はキャッシュしている全ての HTTP オブジェクトが新鮮ではないと考
   えます。つまり、常にキャッシュの中の HTTP オブジェクトをオリジンサーバーへ再
   検証します。
-  Traffic Server はキャッシュしている全ての HTTP オブジェクトを新鮮であると考え
   ます。つまり、オリジンサーバーへ HTTP オブジェクトを再検証することはありません。
-  Traffic Server は ``Expires`` や ``Cache-Control`` ヘッダーを持っていない
   HTTP オブジェクトを新鮮ではないと考えます。つまり、常に ``Expires`` や
   ``Cache-Control`` ヘッダーのない HTTP オブジェクトを再検証します。

Traffic Server がキャッシュしているオブジェクトを再検証する方法を設定
するには `cache.config`_ に特定の再検証のルールを設定してください。

再検証のオプションを設定するには

1. `records.config`_ の次の変数を変更してください。

   -  `proxy.config.http.cache.when_to_revalidate`_

2. ``traffic_line -x`` コマンドを実行して、変更した設定を反映させてください。

Scheduling Updates to Local Cache Content
=========================================

パフォーマンスをはるかに向上させるため、またキャッシュしている HTTP オブジェクト
が新鮮であることを確実にするために、**Scheduled Update** オプションを使うことが
できます。これは特定のオブジェクトをスケジュールされた時間にキャッシュに読み込む
ように Traffic Server を設定します。リバースプロキシーをセットアップしている際に、
負荷が心配されるコンテンツを *preload* することができるという点で特に役に立つこ
とに気づくかもしれません。

計画的アップデートオプションを使うためには次のタスクを行う必要があります。

-  スケジュール通りにアップデートしたいオブジェクトを含む URL のリスト
   、アップデートが実行されるべき時間、URL の再帰する深さを指定してく
   ださい。
-  Scheduled Update オプションを有効にし、オプショナルなリトライ設定を
   指定してください。

Traffic Server は責任を持つ URL を決定するために、指定された情報を使います。
各 URL に対して Traffic Server は (適用可能であれば) 全ての再帰的な URL を
作成し、ユニークな URL リストを生成します。

このリストをもとに、Traffic Server はまだアクセスされていない各 URL に対して
HTTP ``GET`` リクエストを開始します。このリクエストは常に ユーザーが定義した
HTTP の並列度の範囲に収まることが保証されています。システムは全ての HTTP ``GET``
オペレーションの完了を記録します。よって、この機能のパフォーマンスを監視すること
ができます。

Traffic Server は **Force Immediate Update** オプションも提供します。
これは URL を指定されたアップデート時間になるまで待つことなく、すぐに
アップデートすることを可能にします。このオプションをスケジュールされたアップデー
トの設定をテストするために使うことができます。( `Forcing an Immediate Update`_
を参照してください)

Configuring the Scheduled Update Option
---------------------------------------

Scheduled Update オプションを設定するためには

1. `update.config`_ をアップデートしたい URL を一行毎に書いてください
2. `records.config`_ の次の変数を編集してください

   -  `proxy.config.update.enabled`_
   -  `proxy.config.update.retry_count`_
   -  `proxy.config.update.retry_interval`_
   -  `proxy.config.update.concurrent_updates`_

3. ``traffic_line -x`` コマンドを実行して設定の変更を反映してください

Forcing an Immediate Update
---------------------------

Traffic Server は **Force Immediate Update** オプションを提供していま
す。これは `update.config`_ ファイルにリストされた URL を即時に検証す
ることを可能にします。Force Immediate Update オプションは
`update.config`_ ファイルに設定されたオフセット時間と間隔を無視し、リ
ストされた URL を即時的にアップデートします。

Force Immediate Update オプションをセットするには

1. `records.config`_ の次の値を変更してください。

   -  `proxy.config.update.force`_
   -  `proxy.config.update.enabled`_ に 1 が設定されていることを確認してください

2. ``traffic_line -x`` コマンドを実行して設定の変更を反映してください

**重要:** Force Immediate Update オプションを有効にした場合、Traffic
Server はこのオプションが無効化されるまで `update.config`_ ファイルに
指定された URL をアップデートし続けます。Force Immediate Update オプショ
ンを無効化するためには、`proxy.config.update.force`_ 変数を ``0`` (ゼ
ロ) にしてください。

Pushing Content into the Cache
==============================

Traffic Server はコンテンツ配信に HTTP ``PUSH`` メソッドをサポートして
います。HTTP ``PUSH`` を使用すると、クライアントからのリクエスト無しに
コンテンツをキャッシュの中に入れることができます。

Configuring Traffic Server for PUSH Requests
--------------------------------------------

HTTP ``PUSH`` を使用してコンテンツをキャッシュの中に入れる前に、
Traffic Server が ``PUSH`` リクエストを受け入れるように設定する必要が
あります。

Traffic Server が ``PUSH`` リクエストを受け入れる用に設定するには

1. `records.config`_ を編集してください。マスクを ``PUSH`` リクエスト
   を許可するように変更してください。

   -  `proxy.config.http.quick_filter.mask`_

2. push_method を有効にする `records.config`_ の次の変数を変更してください。

   -  `proxy.config.http.push_method_enabled`_

3. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。

Understanding HTTP PUSH
-----------------------

``PUSH`` は HTTP 1.1 メッセージフォーマットを使用します。 ``PUSH`` リク
エストのボディにキャッシュに入れたいレスポンスヘッダーとレスポンスボ
ディを含めてください。下記は ``PUSH`` リクエストの例です。

::

    PUSH http://www.company.com HTTP/1.0
    Content-length: 84

    HTTP/1.0 200 OK
    Content-type: text/html
    Content-length: 17

    <HTML>
    a
    </HTML>

**重要:** ヘッダーは ``Contetnt-length`` を含んでいる必要があります。
つまり ``Contetn-length`` は ``header`` と ``body byte count`` の両方
を含む必要があります。

Tools that will help manage pushing
-----------------------------------

プッシュするための perl スクリプトがあります。`tools/push.pl`_ です。
これはコンテンツをプッシュするためのスクリプトの書き方を理解することに
役立ちます。

Pinning Content in the Cache
============================

**Cache Pinning Option** は特定の時間の間 HTTP オブジェクトをキャッシュ
に確実に入れておくように Traffic Server を設定します。最もポピュラーな
オブジェクトが必要とされるときにキャッシュされていることと、 Traffic
Server が重要なオブジェクトを削除することを防ぐことを確実にしたい際に
このオプションが使えます。Traffic Server は ``Cache-Control`` ヘッダー
を監視し、本当にキャッシュ可能な場合にオブジェクトをキャッシュに留めます。

キャッシュを留めるルールを設定するためには

1. `records.config`_ の次の変数がセットされていることを確認してくださ
   い。

   -  `proxy.config.cache.permit.pinning`_

2. Traffic Server にキャッシュに留めさせたい URL 毎に `cache.config`_
   にルールを追加してください。例:

   ::

       :::text
       url_regex=^https?://(www.)?apache.org/dev/ pin-in-cache=12h

3. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。

To Cache or Not to Cache?
=========================

Traffic Server がキャッシュしていないウェブオブジェクトへのリクエスト
を受け取った際、オリジンサーバーからオブジェクトを回収し、クライアント
に配信します。その際に、Traffic Server は将来のリクエストに備えてキャッ
シュに保存する前に、オブジェクトがキャッシュ可能かどうか確認します。

Caching HTTP Objects
====================

Traffic Server は設定オプションやファイルに指定したディレクティブと同
じように、クライアントやオリジンサーバーからのキャッシュのディレクティ
ブに反応します。

Client Directives
-----------------

デフォルトでは Traffic Server は次の **requires headers** を持つオブジェ
クトをキャッシュ *しません* 。

-  ``Authorization``: header

-  ``Cache-Control: no-store`` header

-  ``Cache-Control: no-cache`` header

   ``Cache-Control: no-cache`` ヘッダーを無視するように Traffic Server
   を設定するには `Configuring Traffic Server to Ignore Client
   no-cache Headers`_ を参照してください。

-  ``Cookie``: header (for text objects)

   デフォルトでは、クッキーを含むようなリクエストへの返答として返され
   るオブジェクト (テキストではないオブジェクト) を Traffic Server は
   キャッシュします。Traffic Server を次の用に設定することができます。
   クッキーを持ったどんなタイプのコンテンツでもキャッシュしない、クッ
   キーを持った全てのコンテンツをキャッシュする、もしくはクッキーを持っ
   た画像だけをキャッシュする。より詳しくは `Caching Cookied Objects`_
   を参照してください。

Configuring Traffic Server to Ignore Client no-cache Headers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

デフォルトでは Traffic Server はクライアントの ``Cache-Control:
no-cache`` ディレクティブを正確に守ります。リクエストされたオブジェ
クトが ``no-cache`` を含んでいる場合、Traffic Server はキャッシュのコ
ピーが新鮮であったとしても、オリジンサーバーにリクエストを転送します。
Traffic Server がクライアントからの ``no-cache`` ディレクティブを無視
するように設定することもできます。この場合、クライアントからのリクエス
トの ``no-cache`` ヘッダーを無視して、キャッシュからオブジェクトを配信
します。

``no-cache`` ヘッダーを無視するように Traffic Server を設定するには

1. `records.config`_ の次の値を変更してください。

   -  `proxy.config.cache.ignore_client_no_cache`_

2. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。

Origin Server Directives
------------------------

デフォルトでは Traffic Server は次の **respons** や **headers** を持つ
ようなオブジェクトをキャッシュ *しません*。

-  ``Cache-Control: no-store`` header
-  ``Cache-Control: private`` header
-  ``WWW-Authenticate``: header

   ``WWW-Authenticate`` ヘッダーを無視するように Traffic Server を設定
   するには `Configuring Traffic Server to Ignore WWW-Authenticate
   Headers`_ を参照してください。

-  ``Set-Cookie``: header
-  ``Cache-Control: no-cache`` headers

   ``no-cache`` ヘッダーを無視するように Traffic Server を設定するには
   `Configuring Traffic Server to Ignore Server no-cache Headers`_ を
   参照してください。

-  ``Expires``: header with value of 0 (zero) or a past date

Configuring Traffic Server to Ignore Server no-cache Headers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

デフォルトでは Traffic Server は ``Cache-Control: no-cache`` ディレク
ティブを正確に守ります。``no-cache`` ヘッダーが付いているオリジンサー
バーからのレスポンスはキャッシュに保存されません。また、キャッシュの中
の古いコピーは削除されます。 ``no-cache`` ヘッダーを無視するように
Traffic Server を設定した場合、Traffic Server は ``no-``\
**``store``** ヘッダーも無視します。``no-cache`` ディレクティブを守る
デフォルトの振る舞いはほとんどの場合に適切です。

``no-cache`` ヘッダーを無視するように Traffic Server を設定するには

1. `records.config`_ の次の値を編集してください。

   -  `proxy.config.cache.ignore_server_no_cache`_

2. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。

Configuring Traffic Server to Ignore WWW-Authenticate Headers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

デフォルトでは Traffic Server は ``WWW-Authenticate`` レスポンスヘッダー
を含むオブジェクトをキャッシュしません。 ``WWW-Authenticate`` ヘッダー
はクライアントがオリジンサーバーへのチャレンジレスポンス認証の際に使う
認証パラメーターを含んでいます。

オリジンサーバーの ``WWW-Authenticate`` ヘッダーを無視するように
Traffic Server を設定した場合、 ``WWW-Authenticate`` ヘッダーを持つ全
てのオブジェクトは次のリクエストの為にキャッシュに保存されます。
しかし、 ``WWW-Authenticate`` ヘッダーを持つオブジェクトをキャッシュし
ないデフォルトの振る舞いは多くの場合に適切です。 ``WWW-Authenticate``
ヘッダーを無視するように Traffic Server を設定するのは HTTP 1.1 に精通しいる
場合にだけにしてください。

``WWW-Authenticate`` ヘッダーを無視するように Traffic Server を設定す
るには

1. `records.config`_ の次の値を変更してください。

   -  `proxy.config.cache.ignore_authentication`_

2. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。

Configuration Directives
------------------------

クライアントやオリジンサーバーのディレクティブに加えて、Traffic Server
は設定オプションやファイルを通じて設定したディレクティブにも反応します。

次のように Traffic Server を設定することができます。

-  どんな HTTP オブジェクトもキャッシュ *しない* (`Disabling HTTP
   Object Caching`_ 参照)
-  **dynamic content** をキャッシュする
   **``.asp``** で終わったり、クエスチョンマーク (**``?``**)、セミコロ
   ン (**``;``**) や **``cgi``** を含んでいたりする URL のオブジェクト
   より詳しくは  `Caching Dynamic Content`_ を参照してください。
-  ``Cookie:`` ヘッダーをに対して返されるオブジェクトをキャッシュする
   (`Caching Cookied Objects`_ 参照)
-  `cache.config`_ ファイルの ``never-cache`` ルールを守る

Disabling HTTP Object Caching
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

デフォルトでは Traffic Server は ```cache.config``
<../configuration-files/cache.config>`_ ファイルに設定した
```never-cache`` <configuration-files/cache.config#action>`_ ルールを
除く全ての HTTP オブジェクトをキャッシュします。後述するように　HTTP
オブジェクトがオリジンサーバーから直接配信され、決してキャッシュされな
いように HTTP オブジェクトのキャッシュを無効化することもできます。

HTTP オブジェクトを手動で無効化するには

1. `recordes.config`_ の次の変数を変更してください。

   -  `proxy.config.cache.http`_

2. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。

Caching Dynamic Content
~~~~~~~~~~~~~~~~~~~~~~~

**``.asp``** で終わったり、クエスチョンマーク (**``?``**)、セミコロン
(**``;``**) や **``cgi``** を含んでいたりする URL  は **動的** である
と考えられます。デフォルトでは Traffic Server は動的コンテンツをキャッ
シュします。動的にコンテンツを探すことを無視するようにシステムを設定で
きます。ただ、これはコンテンツが *本当に* 動的である場合にだけ推奨され
ます。 しかし、 適切な ``Cache-Control`` ヘッダーを公にすることには失
敗します。

動的コンテンツに配慮した Traffic Server の振る舞いを設定するには

1. `recordes.config`_ の次の変数を変更してください。

   -  `proxy.config.http.cache.cache_urls_that_look_dynamic`_

2. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。

Caching Cookied Objects
~~~~~~~~~~~~~~~~~~~~~~~

.. XXX This should be extended to xml as well!

デフォルトではクッキーを含むリクエストに対するレスポンスとして配信され
たオブジェクトを Traffic Server はキャッシュします。これはテキストを除
いた全てのタイプのオブジェクトについても同じです。Traffic Server はクッ
キーをもつテキストコンテンツをキャッシュしません。それは オブジェクト
のヘッダーはオブジェクト共に保存され、個人的なクッキーヘッダーの値もオ
ブジェクトと共に保存されるためです。テキストではないオブジェクトの場合、
個人的なヘッダーは配信されたり使われたりしません。

次のように Traffic Server を設定し直すことができます。

-  クッキーを含む全てのコンテンツをキャッシュ *しない*
-  クッキーを含む画像のみキャッシュする
-  タイプを考慮せずクッキーを含む全てのコンテンツをキャッシュする

クッキーを含むコンテンツをどのようにキャッシュするか Traffic Server を
設定するには

1. `recordes.config`_ の次の変数を変更してください。

   -  `proxy.config.cache_responses_to_cookies`_

2. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。

Forcing Object Caching
======================

You can force Traffic Server to cache specific URLs (including dynamic
URLs) for a specified duration, regardless of ``Cache-Control`` response
headers.

To force document caching

1. Add a rule for each URL you want Traffic Server to pin to the cache
   `cache.config`_:

   ::
       url_regex=^https?://(www.)?apache.org/dev/ ttl-in-cache=6h

2. 設定の変更を適用するために ``traffic_line -x`` コマンドを実行してください。
2. Run the command ``traffic_line -x`` to apply the configuration
   changes.

Caching HTTP Alternates
=======================

Some origin servers answer requests to the same URL with a variety of
objects. The content of these objects can vary widely, according to
whether a server delivers content for different languages, targets
different browsers with different presentation styles, or provides
different document formats (HTML, XML). Different versions of the same
object are termed **alternates** and are cached by Traffic Server based
on ``Vary`` response headers. You can specify additional request and
response headers for specific ``Content-Type``\ s that Traffic Server
will identify as alternates for caching. You can also limit the number
of alternate versions of an object allowed in the cache.

Configuring How Traffic Server Caches Alternates
------------------------------------------------

To configure how Traffic Server caches alternates, follow the steps
below

3. Edit the following variables in `ecords.config`_

   -  `proxy.config.http.cache.enable_default_vary_headers`_
   -  `proxy.config.http.cache.vary_default_text`_
   -  `proxy.config.http.cache.vary_default_images`_
   -  `proxy.config.http.cache.vary_default_other`_

4. Run the command ``traffic_line -x`` to apply the configuration
   changes.

**Note:** If you specify ``Cookie`` as the header field on which to vary
in the above variables, make sure that the variable
`proxy.config.cache.cache_responses_to_cookies`
is set appropriately.

Limiting the Number of Alternates for an Object
-----------------------------------------------

You can limit the number of alternates Traffic Server can cache per
object (the default is 3).

**IMPORTANT:** Large numbers of alternates can affect Traffic Server
cache performance because all alternates have the same URL. Although
Traffic Server can look up the URL in the index very quickly, it must
scan sequentially through available alternates in the object store.

To limit the number of alternates

3. Edit the following variable in `records.config`_

   -  `proxy.config.cache.limits.http.max_alts`_

4. Run the command ``traffic_line -x`` to apply the configuration
   changes.

Using Congestion Control
========================

The **Congestion Control** option enables you to configure Traffic
Server to stop forwarding HTTP requests to origin servers when they
become congested. Traffic Server then sends the client a message to
retry the congested origin server later.

To use the **Congestion Control** option, you must perform the following
tasks:

3. Set the following variable in `records.config`_

   -  `proxy.config.http.congestion_control.enabled`_ to ``1``

-  Create rules in the `congestion.config`_ file to specify:
-  which origin servers Traffic Server tracks for congestion
-  the timeouts Traffic Server uses, depending on whether a server is
   congested
-  the page Traffic Server sends to the client when a server becomes
   congested
-  if Traffic Server tracks the origin servers per IP address or per
   hostname

9. Run the command ``traffic_line -x`` to apply the configuration
   changes.


.. List of links
.. _records.config: configuration-files/records.config
.. _cache.config: configuration-files/cache.config
.. _congestion.config: configuration-files/congestion.config
.. _proxy.config.http.congestion_control.enabled: configuration-files/records.config#proxy.config.http.congestion_control.enabled
.. _proxy.config.cache.limits.http.max_alts: configuration-files/records.config#proxy.config.cache.limits.http.max_alts
.. _proxy.config.http.cache.heuristic_lm_factor: configuration-files/records.config#proxy.config.http.cache.heuristic_lm_factor
.. _proxy.config.http.cache.heuristic_min_lifetime: configuration-files/records.config#proxy.config.http.cache.heuristic_min_lifetime
.. _proxy.config.http.cache.heuristic_max_lifetime: configuration-files/records.config#proxy.config.http.cache.heuristic_max_lifetime
.. _proxy.config.http.cache.when_to_revalidate: configuration-files/records.config#proxy.config.http.cache.when_to_revalidate
.. _proxy.config.update.enabled: configuration-files/records.config#proxy.config.update.enabled
.. _proxy.config.update.retry_count: configuration-files/records.config#proxy.config.update.retry_count
.. _proxy.config.update.concurrent_updates: configuration-files/records.config#proxy.config.update.concurrent_updates
.. _proxy.config.update.force: configuration-files/records.config#proxy.config.update.force
.. _proxy.config.http.quick_filter.mask: configuration-files/records.config#proxy.config.http.quick_filter.mask
.. _proxy.config.http.push_method_enabled: configuration-files/records.config#proxy.config.http.push_method_enabled
.. _proxy.config.cache.permit.pinning: configuration-files/records.config#proxy.config.cache.permit.pinning
.. _proxy.config.cache.ignore_server_no_cache: configuration-files/records.config#proxy.config.cache.ignore_server_no_cache
.. _proxy.config.cache.ignore_authentication: configuration-files/records.config#proxy.config.cache.ignore_authentication
.. _proxy.config.cache.http: configuration-files/records.config#proxy.config.cache.http
.. _proxy.config.http.cache.cache_urls_that_look_dynamic: configuration-files/records.config#proxy.config.http.cache.cache_urls_that_look_dynamic
.. _proxy.config.cache_responses_to_cookies: configuration-files/records.config#proxy.config.cache_responses_to_cookies
.. _proxy.config.http.cache.enable_default_vary_headers: configuration-files/records.config#proxy.config.http.cache.enable_default_vary_headers
.. _proxy.config.http.cache.vary_default_text: configuration-files/records.config#proxy.config.http.cache.vary_default_text
.. _proxy.config.http.cache.vary_default_images: configuration-files/records.config#proxy.config.http.cache.vary_default_images
.. _proxy.config.http.cache.vary_default_other: configuration-files/records.config#proxy.config.http.cache.vary_default_other
.. _proxy.config.cache.cache_responses_to_cookies: configuration-files/records.config#proxy.config.cache.cache_responses_to_cookies

.. _tools/push.pl: http://git-wip-us.apache.org/repos/asf?p=trafficserver.git;a=blob;f=tools/push.pl
