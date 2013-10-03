Administrators's Guide
**********************

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


Apache Traffic Server™ はインターネットアクセスを加速させ、ウェブサイトの
パフォーマンスを高め、かつて無いウェブホスティング性能を提供します。

この章は次のようなトピックについて書いてあります。

Contents:

.. toctree::
   :maxdepth: 2

   getting-started.en
   http-proxy-caching.en
   reverse-proxy-http-redirects.en
   forward-proxy.en
   transparent-proxy.en
   explicit-proxy-caching.en
   hierachical-caching.en
   configuring-cache.en
   monitoring-traffic.en
   configuring-traffic-server.en
   cluster-howto.en
   security-options.en
   working-log-files.en
   event-logging-formats.en
   configuration-files.en
   traffic-line-commands.en
   traffic-server-error-messages.en
   faqs.en
   plugins.en


Apache Traffic Server とは？
==============================

グローバルデータネットワークは毎日の一部になっています。つまり
インターネットユーザーは日常生活の基盤の上で数１０億ものドキュメントや
テラバイトのデータを世界の隅から隅へリクエストします。
不幸なことに、グローバルデータネットワーキングは過負荷なサーバーや
混雑したネットワークと格闘している IT 専門家にとっては悪夢です。
増え続けるデータ需要を絶えず、期待通りに動くように対応することは
チャレンジングなことです。

Traffic Server は高性能なウェブプロキシーキャッシュで、ネットワーク効率と
パフォーマンスを頻繁にアクセスされる情報をネットワークの端でキャッシュすることで
改善します。これはエンドユーザーに物理的に近いコンテンツを届ける一方で配信と
帯域使用量を減らすことを可能とします。Traffic Server は商用のコンテンツ配信や
インターネットサービスプロバイダー( ISP )やバックボーンプロバイダーや
巨大なイントラネットを現行の利用可能な帯域を最大化することで改善するように
デザインされています。

Traffic Server デプロイメントオプション
=======================================

必要に応じて、Traffic Server はいくつかの方法で配置することができます。

- ウェブプロキシーキャッシュ
- リバースプロキシー
- キャッシュヒエラルキーの一部

次のセクションではこれらの Traffic Server のデプロイメントオプションの概要を
説明します。これらのすべてのプションで Traffic Server は *シングルインスタンス*
か *マルチノードクラスター* として動作することを覚えておいて
下さい。

ウェブプロキシーとしての Traffic Server
---------------------------------------

ウェブプロキシーキャッシュとして、Traffic Server はウェブコンテンツ
のユーザーリクエストを受け取り、宛先のウェブサーバー
(オリジンサーバー)へ届けます。
リクエストこんテンスがキャッシュから使えない場合、
Traffic Server はプロキシーとして振る舞います。つまり、コンテンツを
ユーザーに代わってコンテンツを取得し、また将来のリクエストを満たす
ためにコピーを保持します。

Traffic Server は明確なプロキシーキャッシュを提供します。この場合ユーザーの
クライアントソフトウェアは Traffic Server に直接リクエストを送るように設定され
ていなければなりません。明確なプロキシーキャッシュについては `Explicit Proxy
Caching <explicit-proxy-caching>`_  の章で述べています。

リバースプロキシーとしての Traffic Server
-----------------------------------------

リバースプロキシーとして Traffc Server はユーザーが接続しようとする
オリジンサーバーとして設定されています。(一般的に、オリジンサーバーとして
宣伝されたホスト名は Traffic Server に解決され、実際のオリジンサーバーの
ように振る舞います。)リバースプロキシー機能はサーバーアクセラレーション
とも呼ばれます。リバースプロキシーは `Reverse proxy and HTTP Redirects
<reverse-proxy-http-redirects>`_ で詳しく述べられています。

キャッシュヒエラルキーの中の Traffic Server
-------------------------------------------

Traffic Server は柔軟にキャッシュヒエラルキーに参加することができます。
その中で 一つのキャッシュからは満たされないインターネットリクエストは他の
コンテンツを支配していて、近いキャッシュに近接している局部的なキャッシュへ
送られます。プロキシーサーバーの階層の中で Traffic Server は他のTraffic Server
システムや似たキャッシングプロダクトの親や子として振る舞います。

Traffic Server は ICP(Internet Cache Protocol) のピアイングをサポートしています。
階層的キャッシュは `Hierarchical Caching <hierachical-caching>`_ で
詳しく述べられています。

Traffic Server Components
=========================

Traffic Server はウェブプロキシーキャッシュとして簡単に監視や設定ができるように
構成されたいくつかコンポーネントによって構成されています。
これらのコンポーネントについて次に述べます。

The Traffic Server Cache
------------------------

Traffic Server キャッシュはオブジェクトストアと呼ばれるハイスピードオブジェクトデータベース
によって構成されます。オブジェクトは URL と関連するヘッダーに基づいたインデックス
オブジェクトを保存します。洗練されたオブジェクト管理により、オブジェクトストアは同じ
オブジェクトの（言語やエンコーディングタイプなどが）異なるバージョンをキャッシュする
ことができます。これは無駄なスペースを最小化することによって、とても小さかったり、
大きかったりするオブジェクトを効率的に保存することもできます。キャッシュがいっぱいに
なった場合、Traffic Server は最もリクエストされるオブジェクトがすぐに利用可能で
新しい状態であることを保証するために、古いデータを削除します。

Traffic Server はすべてのキャッシュディスクのあらゆるディスク不良を
許容するようにデザインされています。完全にディスクが壊れてしまった
場合、Traffic Server はそのディスクを破損したと印をつけ、残りの
ディスクを使い続けます。すべてのディスクが壊れた場合、
Traffic Server は proxy-only モードに切り替わります。
特定のプロトコルやオリジンサーバーのデータを保存するための一定の
ディスクスペースを予約するためにキャッシュを分割することができます。
キャッシュに関するより詳しい情報は `Configuring the Cache
<configuring-cache>`_を参照してください。

The RAM Cache
-------------

Traffic Server はとても頻繁にアクセスされるオブジェクトを含む小さな RAM
キャッシュを持っています。特に一時的なトラフィックのピークの間に、
このRAM キャッシュは最もポピュラーなオブジェクトを可能な限り速く提供し、
ディスクからのロードを減らします。この RAM キャッシュのサイズは必要な量に
設定することができます。より詳しい情報は `Changing the Size of the RAM
Cache <configuring-cache#ChangingSizeofRAMCache>`_ を参照してください。

The Host Database
-----------------

Traffic Server は Traffic Server がユーザーリクエストを満たすために接続
するオリジンサーバーの ドメインネームサーバー(DNS) のエントリを保存する
データーベースをホストします。この情報は将来のプロトコルインタラクション
への対応とパフォーマンスの最適化のために使われます。加えて、ホストデータ
ベースは次の情報を保存します。

- DNS 情報(ホストネームから IP アドレスを高速に引くため)
- 各ホストの HTTP バージョン(最新のプロトコルの機能はモダンなサーバーで
  使われているかもしれないため)
- 信頼性と可用性の情報(ユーザーが起動していないサーバーを待つことが
  ないように)

The DNS Resolver
----------------

Traffic Server はホスト名から IP アドレスへの変換を統合するために、高速
で非同期な DNS リゾルバも含んでいます。Traffic Server は遅くて月並みな
リゾルバライブラリに渡すよりも、直接 DNS コマンドパケットを渡すことに
よって、DNS リゾルバをネイティブに実行します。多くの DNS クエリが並列で
渡され、高速な DNS キャッシュがポピュラーなバインディングをメモリに保存
することにより、DNS トラフィックは減ります。

Traffic Server Processes
------------------------

Traffic Server はリクエストを返し、システムの状態を管理/制御/監視すること
を協調して動くための3つのプロセスを含んでいます。
この３つのプロセスは下に説明されています。

- ``traffic_server`` プロセスは Traffic Server のトランザクションプロセッ
  シングエンジンです。コネクションをアクセプトしたり、プロトコルリクエスト
  を処理したり、キャッシュやオリジンサーバーからドキュメントを提供することに
  責任を持ちます。

- ``traffic_manager`` プロセスは Traffic Server への命令と管理機能です。
  起動や監視と ``traffic_server`` プロセスを再設定したりすることに責任を
  持ちます。
  ``traffic_manager`` プロセスはプロキシオートコンフィギュレーションポートや
  統計のインターフェイスやクラスター管理とバーチャル IP フェイルオーバーに
  ついても責任を持ちます。

  ``traffic_manager`` プロセスが ``traffic_server`` プロセスが失敗している
  ことを検知した場合、即座にプロセスを再起動するだけでなく、すべての
  リクエストのコネクションキューをメンテナンスします。
  サーバーが完全に再起動する数秒前に到着したすべてのインカミング
  コネクションはコネクションキューに格納され、最初に来たものから順に処理されます。
  このコネクションキューはすべてのサーバーの再起動の際のダウンタイムから
  ユーザーを守ります。

- ``traffic_cop`` プロセスは ``traffic_server`` と ``traffic_manager``
  プロセスの両方の状態をモニターします。
  ``traffic_cop`` プロセスは定期的(毎分数回)に静的なウェブページを
  取得するハートビートリクエストを渡すことで ``traffic_server`` と
  ``traffic_manager`` に問い合わせます。
  失敗したとき(一定期間の間にレスポンスが帰って来ないときや不正な
  レスポンスを受け取ったとき), ``traffic_cop`` は ``traffic_manager`` と
  ``traffic_server`` プロセスを再起動します。

次の図は Traffic Server の3つのイラストです。

.. figure:: ../static/images/admin/process.jpg
   :align: center
   :alt: Illustration of the three Traffic Server Processes

   Illustration of the three Traffic Server Processes

管理ツール
----------

Traffic Server は次のような管理オプションを提供しています。

-  Traffic Line コマンドラインインターフェイスはテキストベースのインター
   フェースです。Traffic Server のパフォーマンスとネットワークトラフィック
   を監視できます。また同じように、Traffic Server システムを設定することも
   できます。Traffic Line によって独立したコマンドや一連のコマンドの
   スクリプトをシェルで実行することができます。
-  Traffic Shell コマンドラインインターフェイスは追加のコマンドラインツールで、Traffic
   Server システムを監視したり設定したりする独立したコマンドを実行することができます。
   Traffic Line や Traffic Shell を通じたどんな変更も自動的に設定ファイルを作ります。
-  様々な設定ファイルはシンプルなファイル編集とシグナルハンドリングインターフェースを
   通して、 Traffic Server を設定することを可能とします。
   Traffic Line か Traffic Shell を通じたどのような変更でも自動的に
   設定ファイルに書き込まれます。
-  最後に、多くのな言語から使うことのできるクリーンな C API
   があります。
   Traffic Server Admin Client は Perl でこのことを示しています。

Traffic 分析オプション
======================

Traffic Server はネットワークトラフィックの分析と監視のためのいくつかのオプション
を提供しています。

-  Traffic Line と Traffic Shell はネットワークトラフィック情報から
   入手した統計情報を集めて処理することを可能にします。

-  トランザクションロギングは Traffic Server が処理したへすべてのリクエストと
   すべての検知したエラーの情報を (ログファイルの中に) 記録することを可能にします。
   ログファイルを分析することによって、どれほどのクライアントが Traffic Sever
   キャッシュを使用し、どれくらいの情報がリクエストされ、どのページがポピュラー
   なのかを確認することができます。
   特定のトランザクションがなぜエラーになり、 そのときの Traffic Server の状態が
   どうだったのかみることもできます。例えば、Traffic Server が再起動したときや、
   クラスターコミュニケーションがタイムアウトしたときなどです。

   Traffic Server は Squid や Netscape などのいくつかの標準的なログフォーマットや
   固有のフォーマットをサポートしています。
   off-the-shelf 分析パッケージによって標準的なフォーマットのログを分析することが
   できます。ログファイルの分析を助けるために、特定のプロトコルやホストの情報を
   含むようにログファイルを分割することができます。

トラフィック分析オプションは `Monitoring Traffic <monitoring-traffic>`_ により
詳しく書かれています。

Traffic Server ロギングオプションは `Working with Log Files <working-log-files>`_
に書かれています。

Traffic Server セキュリティオプション
=====================================

Traffic Server は Traffic Server システムと他のコンピュータネットワーク
間のセキュアな通信を確立することを可能にする多数のオプションを
提供しています。セキュリティオプションを使うことによって、
次のようなことができます。

-  Traffic Server プロキシーキャッシュにアクセスするクライアントの管理
-  あなたのサイトのセキュリティ設定にマッチする複数の DNS サーバーを
   使うための Traffic Server の管理
   例えば、Traffic Server はホストネームを解決する必要があるのが
   ファイアーウォールの内側か外側かによって異なる DNS サーバーを使うことができます。
   これは透過的にインターネット上の外部サイトにアクセスすることを提供しつつ、
   インターナルネットワーク設定をセキュアに保つことを可能にします。
-  クライアントが Traffic Server キャッシュからコンテンツにアクセスできるようになる
   前に、クライアントが認証されていることを検証する Traffic Server 設定
-  SSL ターミネーションオプションを使うことによる、リバースプロキシーモード
   でのクライアントと Traffic Server 間と Traffic Server とオリジンサーバー
   間の安全な接続
-  SSL (Secure Socket Layer) によるアクセスの管理

Traffic Server セキュリティオプションは `Security Options <security-options>`_
に詳しく述べられています。

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
