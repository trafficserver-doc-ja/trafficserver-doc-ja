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
   Traffic Server はオブジェクトがフレッシュであるかどうかを決定するために、
   現在時刻と有効期限を比較します。

-  **Checking the ``Last-Modified`` / ``Date`` header**

   HTTP オブジェクトが ``Expire`` ヘッダーや ``max-age`` ヘッダーを持っていない場合、
   Traffic Server はフレッシュネスリミットを
   次の式で計算します。

   ::
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
 ``Last-Modified`` と ``Date`` ヘッダーからフレッシュネスを見積もります。
デフォルトでは Traffic Server は最後に更新されてからの経過時間の 10 %
キャッシュします。
必要に応じて、増減することができます。

フレッシュネスの計算のための期間の要素を変更するためには、

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

To further ensure freshness of the objects in the cache, configure
Traffic Server to cache only objects with specific headers. By default,
Traffic Server caches all objects (including objects with no headers);
you should change the default setting only for specialized proxy
situations. If you configure Traffic Server to cache only HTTP objects
with ``Expires`` or ``max-age`` headers, then the cache hit rate will be
noticeably reduced (since very few objects will have explicit expiration
information).

To configure Traffic Server to cache objects with specific headers

1. Edit the following variable in `records.config`_

   -  `proxy.config.http.cache.required_headers`_

2. Run the ``traffic_line -x`` command to apply the configuration
   changes.

Cache-Control Headers
---------------------

Even though an object might be fresh in the cache, clients or servers
often impose their own constraints that preclude retrieval of the object
from the cache. For example, a client might request that a object *not*
be retrieved from a cache, or if it does, then it cannot have been
cached for more than 10 minutes. Traffic Server bases the servability of
a cached object on ``Cache-Control`` headers that appear in both client
requests and server responses. The following ``Cache-Control`` headers
affect whether objects are served from cache:

-  The ``no-cache`` header, sent by clients, tells Traffic Server that
   it should not to serve any objects directly from the cache;
   therefore, Traffic Server will always obtain the object from the
   origin server. You can configure Traffic Server to ignore client
   ``no-cache`` headers - refer to `Configuring Traffic Server to Ignore Client no-cache Headers`_
   for more information.

-  The ``max-age`` header, sent by servers, is compared to the object
   age. If the age is less than ``max-age``, then the object is fresh
   and can be served.

-  The ``min-fresh`` header, sent by clients, is an **acceptable
   freshness tolerance**. This means that the client wants the object to
   be at least this fresh. Unless a cached object remains fresh at least
   this long in the future, it is revalidated.

-  The ``max-stale`` header, sent by clients, permits Traffic Server to
   serve stale objects provided they are not too old. Some browsers
   might be willing to take slightly stale objects in exchange for
   improved performance, especially during periods of poor Internet
   availability.

Traffic Server applies ``Cache-Control`` servability criteria
***after*** HTTP freshness criteria. For example, an object might be
considered fresh but will not be served if its age is greater than its
``max-age``.

Revalidating HTTP Objects
-------------------------

When a client requests an HTTP object that is stale in the cache,
Traffic Server revalidates the object. A **revalidation** is a query to
the origin server to check if the object is unchanged. The result of a
revalidation is one of the following:

-  If the object is still fresh, then Traffic Server resets its
   freshness limit and serves the object.

-  If a new copy of the object is available, then Traffic Server caches
   the new object (thereby replacing the stale copy) and simultaneously
   serves the object to the client.

-  If the object no longer exists on the origin server, then Traffic
   Server does not serve the cached copy.

-  If the origin server does not respond to the revalidation query, then
   Traffic Server serves the stale object along with a
   ``111 Revalidation Failed`` warning.

By default, Traffic Server revalidates a requested HTTP object in the
cache if it considers the object to be stale. Traffic Server evaluates
object freshness as described in `HTTP Object Freshness`_.
You can reconfigure how Traffic
Server evaluates freshness by selecting one of the following options:

-  Traffic Server considers all HTTP objects in the cache to be stale:
   always revalidate HTTP objects in the cache with the origin server.
-  Traffic Server considers all HTTP objects in the cache to be fresh:
   never revalidate HTTP objects in the cache with the origin server.
-  Traffic Server considers all HTTP objects without ``Expires`` or
   ``Cache-control`` headers to be stale: revalidate all HTTP objects
   without ``Expires`` or ``Cache-Control`` headers.

To configure how Traffic Server revalidates objects in the cache, you
can set specific revalidation rules in `cache.config`_.

To configure revalidation options

1. Edit the following variable in `records.config`_

   -  `proxy.config.http.cache.when_to_revalidate`_

2. Run the ``traffic_line -x`` command to apply the configuration
   changes.

Scheduling Updates to Local Cache Content
=========================================

To further increase performance and to ensure that HTTP objects are
fresh in the cache, you can use the **Scheduled Update** option. This
configures Traffic Server to load specific objects into the cache at
scheduled times. You might find this especially beneficial in a reverse
proxy setup, where you can *preload* content you anticipate will be in
demand.

To use the Scheduled Update option, you must perform the following
tasks.

-  Specify the list of URLs that contain the objects you want to
   schedule for update,
-  the time the update should take place,
-  and the recursion depth for the URL.
-  Enable the scheduled update option and configure optional retry
   settings.

Traffic Server uses the information you specify to determine URLs for
which it is responsible. For each URL, Traffic Server derives all
recursive URLs (if applicable) and then generates a unique URL list.
Using this list, Traffic Server initiates an HTTP ``GET`` for each
unaccessed URL. It ensures that it remains within the user-defined
limits for HTTP concurrency at any given time. The system logs the
completion of all HTTP ``GET`` operations so you can monitor the
performance of this feature.

Traffic Server also provides a **Force Immediate Update** option that
enables you to update URLs immediately without waiting for the specified
update time to occur. You can use this option to test your scheduled
update configuration (refer to `Forcing an Immediate Update`_).

Configuring the Scheduled Update Option
---------------------------------------

To configure the scheduled update option

1. Edit `update.config`_ to
   enter a line in the file for each URL you want to update.
2. Edit the following variables in `records.config`_

   -  `proxy.config.update.enabled`_
   -  `proxy.config.update.retry_count`_
   -  `proxy.config.update.retry_interval`_
   -  `proxy.config.update.concurrent_updates`_

3. Run the ``traffic_line -x`` command to apply the configuration
   changes.

Forcing an Immediate Update
---------------------------

Traffic Server provides a **Force Immediate Update** option that enables
you to immediately verify the URLs listed in the `update.config`_ file.
The Force Immediate Update option disregards the offset hour and
interval set in the `update.config`_ file and immediately updates the
URLs listed.

To configure the Force Immediate Update option

1. Edit the following variables in `records.config`_

   -  `proxy.config.update.force`_
   -  Make sure the variable
      `proxy.config.update.enabled`_ is set to 1.

2. Run the ``command traffic_line -x`` to apply the configuration
   changes.

**IMPORTANT:** When you enable the Force Immediate Update option,
Traffic Server continually updates the URLs specified in the
`update.config`_ file until you disable the option. To disable the
Force Immediate Update option, set the variable
`proxy.config.update.force`_ to ``0`` (zero).

Pushing Content into the Cache
==============================

Traffic Server supports the HTTP ``PUSH`` method of content delivery.
Using HTTP ``PUSH``, you can deliver content directly into the cache
without client requests.

Configuring Traffic Server for PUSH Requests
--------------------------------------------

Before you can deliver content into your cache using HTTP ``PUSH``, you
must configure Traffic Server to accept ``PUSH`` requests.

To configure Traffic Server to accept ``PUSH`` requests

1. Edit `records.config`_, modify the super mask to allow ``PUSH`` request.

   -  `proxy.config.http.quick_filter.mask`_

2. Edit the following variable in `records.config`_, enable
   the push_method.

   -  `proxy.config.http.push_method_enabled`_

3. Run the command ``traffic_line -x`` to apply the configuration
   changes.

Understanding HTTP PUSH
-----------------------

``PUSH`` uses the HTTP 1.1 message format. The body of a ``PUSH``
request contains the response header and response body that you want to
place in the cache. The following is an example of a ``PUSH`` request:

::

    PUSH http://www.company.com HTTP/1.0
    Content-length: 84

    HTTP/1.0 200 OK
    Content-type: text/html
    Content-length: 17

    <HTML>
    a
    </HTML>

**IMPORTANT:** Your header must include ``Content-length`` -
``Content-length`` must include both ``header`` and ``body byte count``.

Tools that will help manage pushing
-----------------------------------

There is a perl script for pushing, `tools/push.pl`_,
which can help you understanding how to write some script for pushing
content.

Pinning Content in the Cache
============================

The **Cache Pinning Option** configures Traffic Server to keep certain
HTTP objects in the cache for a specified time. You can use this option
to ensure that the most popular objects are in cache when needed and to
prevent Traffic Server from deleting important objects. Traffic Server
observes ``Cache-Control`` headers and pins an object in the cache only
if it is indeed cacheable.

To set cache pinning rules

3. Make sure the following variable in `records.config`_ is set

   -  `proxy.config.cache.permit.pinning`_

4. Add a rule in `cache.config`_ for each
   URL you want Traffic Server to pin in the cache. For example:

   ::

       :::text
       url_regex=^https?://(www.)?apache.org/dev/ pin-in-cache=12h

5. Run the command ``traffic_line -x`` to apply the configuration
   changes.

To Cache or Not to Cache?
=========================

When Traffic Server receives a request for a web object that is not in
the cache, it retrieves the object from the origin server and serves it
to the client. At the same time, Traffic Server checks if the object is
cacheable before storing it in its cache to serve future requests.

Caching HTTP Objects
====================

Traffic Server responds to caching directives from clients and origin
servers, as well as directives you specify through configuration options
and files.

Client Directives
-----------------

By default, Traffic Server does *not* cache objects with the following
**request headers**:

-  ``Authorization``: header

-  ``Cache-Control: no-store`` header

-  ``Cache-Control: no-cache`` header

   To configure Traffic Server to ignore the ``Cache-Control: no-cache``
   header, refer to `Configuring Traffic Server to Ignore Client no-cache Headers`_

-  ``Cookie``: header (for text objects)

   By default, Traffic Server caches objects served in response to
   requests that contain cookies (unless the object is text). You can
   configure Traffic Server to not cache cookied content of any type,
   cache all cookied content, or cache cookied content that is of image
   type only. For more information, refer to `Caching Cookied Objects`_.

Configuring Traffic Server to Ignore Client no-cache Headers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, Traffic Server strictly observes client
``Cache-Control: no-cache`` directives. If a requested object contains a
``no-cache`` header, then Traffic Server forwards the request to the
origin server even if it has a fresh copy in cache. You can configure
Traffic Server to ignore client ``no-cache`` directives such that it
ignores ``no-cache`` headers from client requests and serves the object
from its cache.

To configure Traffic Server to ignore client ``no-cache`` headers

3. Edit the following variable in `records.config`_

   -  `proxy.config.cache.ignore_client_no_cache`

4. Run the command ``traffic_line -x`` to apply the configuration
   changes.

Origin Server Directives
------------------------

By default, Traffic Server does *not* cache objects with the following
**response** **headers**:

-  ``Cache-Control: no-store`` header
-  ``Cache-Control: private`` header
-  ``WWW-Authenticate``: header

   To configure Traffic Server to ignore ``WWW-Authenticate`` headers,
   refer to `Configuring Traffic Server to Ignore WWW-Authenticate Headers`_.

-  ``Set-Cookie``: header
-  ``Cache-Control: no-cache`` headers

   To configure Traffic Server to ignore ``no-cache`` headers, refer to
   `Configuring Traffic Server to Ignore Server no-cache Headers`_.

-  ``Expires``: header with value of 0 (zero) or a past date

Configuring Traffic Server to Ignore Server no-cache Headers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, Traffic Server strictly observes ``Cache-Control: no-cache``
directives. A response from an origin server with a ``no-cache`` header
is not stored in the cache and any previous copy of the object in the
cache is removed. If you configure Traffic Server to ignore ``no-cache``
headers, then Traffic Server also ignores ``no-``\ **``store``**
headers. The default behavior of observing ``no-cache`` directives is
appropriate in most cases.

To configure Traffic Server to ignore server ``no-cache`` headers

3. Edit the following variable in `records.config`_

   -  `proxy.config.cache.ignore_server_no_cache`_

4. Run the command ``traffic_line -x`` to apply the configuration
   changes.

Configuring Traffic Server to Ignore WWW-Authenticate Headers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, Traffic Server does not cache objects that contain
``WWW-Authenticate`` response headers. The ``WWW-Authenticate`` header
contains authentication parameters the client uses when preparing the
authentication challenge response to an origin server.

When you configure Traffic Server to ignore origin server
``WWW-Authenticate`` headers, all objects with ``WWW-Authenticate``
headers are stored in the cache for future requests. However, the
default behavior of not caching objects with ``WWW-Authenticate``
headers is appropriate in most cases. Only configure Traffic Server to
ignore server ``WWW-Authenticate`` headers if you are knowledgeable
about HTTP 1.1.

To configure Traffic Server to ignore server ``WWW-Authenticate``
headers

3. Edit the following variable in `records.config`_

   -  `proxy.config.cache.ignore_authentication`_

4. Run the command ``traffic_line -x`` to apply the configuration
   changes.

Configuration Directives
------------------------

In addition to client and origin server directives, Traffic Server
responds to directives you specify through configuration options and
files.

You can configure Traffic Server to do the following:

-  *Not* cache any HTTP objects (refer to `Disabling HTTP Object Caching`_).
-  Cache **dynamic content** - that is, objects with URLs that end in
   **``.asp``** or contain a question mark (**``?``**), semicolon
   (**``;``**), or **``cgi``**. For more information, refer to `Caching Dynamic Content`_.
-  Cache objects served in response to the ``Cookie:`` header (refer to
   `Caching Cookied Objects`_.
-  Observe ``never-cache`` rules in the `cache.config`_ file.

Disabling HTTP Object Caching
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, Traffic Server caches all HTTP objects except those for
which you have set
```never-cache`` <configuration-files/cache.config#action>`_ rules in
the ```cache.config`` <../configuration-files/cache.config>`_ file. You
can disable HTTP object caching so that all HTTP objects are served
directly from the origin server and never cached, as detailed below.

To disable HTTP object caching manually

3. Edit the following variable in `records.config`_

   -  `proxy.config.cache.http`_

4. Run the command ``traffic_line -x`` to apply the configuration
   changes.

Caching Dynamic Content
~~~~~~~~~~~~~~~~~~~~~~~

A URL is considered **dynamic** if it ends in **``.asp``** or contains a
question mark (**``?``**), a semicolon (**``;``**), or **``cgi``**. By
default, Traffic Server caches dynamic content. You can configure the
system to ignore dyanamic looking content, although this is recommended
only if the content is *truely* dyanamic, but fails to advertise so with
appropriate ``Cache-Control`` headers.

To configure Traffic Server's cache behaviour in regard to dynamic
content

3. Edit the following variable in `records.config`_

   -  `proxy.config.http.cache.cache_urls_that_look_dynamic`

4. Run the command ``traffic_line -x`` to apply the configuration
   changes.

Caching Cookied Objects
~~~~~~~~~~~~~~~~~~~~~~~

.. XXX This should be extended to xml as well!

By default, Traffic Server caches objects served in response to requests
that contain cookies. This is true for all types of objects except for
text. Traffic Server does not cache cookied text content because object
headers are stored along with the object, and personalized cookie header
values could be saved with the object. With non-text objects, it is
unlikely that personalized headers are delivered or used.

You can reconfigure Traffic Server to:

-  *Not* cache cookied content of any type.
-  Cache cookied content that is of image type only.
-  Cache all cookied content regardless of type.

To configure how Traffic Server caches cookied content

3. Edit the following variable in `records.config`_

   -  `proxy.config.cache_responses_to_cookies`_

4. Run the command ``traffic_line -x`` to apply the configuration
   changes.

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
