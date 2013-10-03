Getting Started
***************

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


.. toctree::
   :maxdepth: 2

Before you start
================

Traffic Server を始める前に、どのバージョンを使いたいか決める
必要があります。Traffic Server は Apache
`apr <http://apr.apache.org/versioning.html>`_ や
`httpd <http://httpd.apache.org/dev/release.html>`_ が行っているように
"安定性"を示すために、"セマンティック バージョニング" を使用しています。

バージョンは次のような三つ組みのバージョンで構成されています。 *``MAJOR.MINOR.PATCH``*

最も重要なことは *``MINOR``* が偶数のもの ( 3.0.3 や 3.2.5 のような) は
プロダクション安定リリースで、*``MINOR``* が奇数のものは開発者向けであることを
示していることを知っていることです。

トランク、マスター、もしくは実際のリリースについて話しているとき、"-unstabe" や "-dev" といった言い方をします。
トランク、マスター、TIP、HEAD のような Version Control System 内の最新のコードの呼び方はすべて交換可能です。
しかし、"-dev" (もしくは 不運なことに "-unstable" と名前づけられたもの) は次のことがわかります。
"3.3.1-dev"のような特定のリリースはプロダクションレディーなものとみなせる程の十分なテストを受けていません。

| 訳注: この偶数/奇数で安定版/開発版を分けるバージョンの付け方は 3.x 系までのようです。
| 4.x 系からは Rapid Release を採用するため、この方式は廃止されるようです。

お使いのディストリビューションが Traffic Server をあらかじめパッケージされていない場合、
`downloads </downloads>`_ へ行き、最も適切だと考えられるバージョンを選んでください。
最先端のものが本当に欲しい場合は、
`git repository <https://git-wip-us.apache.org/repos/asf/trafficserver.git>`_.
 からクローンすることができます。

Pull-Request を送ることができる
`GitHub Mirror <https://github.com/apache/trafficserver>`_
を持っていますが、これはこれは最新版ではないかもしれないことに注意してください。

Building Traffic Server
=======================

Traffic Server をソースコードからビルドするために、
次の(開発)パッケージが必要です。

-  pkgconfig
-  libtool
-  gcc (>= 4.3 or clang > 3.0)
-  make (GNU Make!)
-  openssl
-  tcl
-  expat
-  pcre
-  pcre
-  libcap
-  flex (for TPROXY)
-  hwloc
-  lua

git クローンからビルドする場合は、次のものも必要です。

-  git
-  autoconf
-  automake

git からビルドする例をお見せしましょう。

::

     git clone https://git-wip-us.apache.org/repos/asf/trafficserver.git

次に、``cd trafficserver`` を実行し、次のコマンドを実行します。

::

     autoreconf -if

これは ``configure`` ファイルを ``configure.ac`` から生成するので、
次のコマンドを実行できます。

::

     ./configure --prefix=/opt/ats

デフォルトでは Traffic Server ユーザーとして ``nobody`` ユーザーを
使用することに注意してください。プライマリーグループについても同様です。
これを変更したい場合、上書きすることができます。

::

     ./configure --prefix=/opt/ats --with-user=tserver

標準的なパス ( ``/usr/local`` や ``/usr`` ) に依存関係がない場合、
次のように ``configure`` にオプションを通す必要があります。

::

     ./configure --prefix=/opt/ats --with-user=tserver --with-lua=/opt/csw

ほとんどの ``configure`` パスオプションは ``"INCLUDE_PATH:LIBRARY_PATH"``
というフォーマットを受け入れます。

::

     ./configure --prefix=/opt/ats --with-user=tserver --with-lua=/opt/csw \
        --with-pcre=/opt/csw/include:/opt/csw/lib/amd64

プロジェクトをビルドするために ``make`` コマンドを実行しましょう。
ビルドの一般的な正常さを確かめるために ``make check`` コマンドを実行することを強く推奨します。

::

     make
     make check

最後に ``make install`` コマンドを実行しましょう。
(おそらく root になることが必要でしょう)

::

     sudo make install

レグレッションテストを実行することも推奨します。
これはデフォルト``レイアウト``で正常に動作することに注意してください。

::

     cd /opt/ats
     sudo bin/traffic_server -R 1

Traffic Server をシステム上にインストースした後、
次のどれでもできます。

Start Traffic Server
====================

Traffic Server を手動で起動するには ``trafficserver`` コマンドに
``start`` を発行します。
このコマンドは Traffic Server へのリクエストを処理したり、Traffic Server
システムの状態を管理、制御、監視するためのすべてのプロセスを起動します。

``trafficserver start`` コマンドを実行するには次のようにします。

::

        bin/trafficserver start

この時点でサーバーは  `reverse proxy <../reverse-proxy-http-redirects>`_.
のデフォルト設定で起動し、走っています。

Start Traffic Line
==================

Traffic Line は Traffic Server の統計を見たり、コマンドラインインターフェースによる
 Traffic Server の設定をする簡単な方法を提供しています。
独立したコマンドの実行または複数のコマンドのスクリプトについては
`Traffic Line Commands <../traffic-line-commands>`_. を参照してください。

Traffic Line コマンドは次のようなフォームを受け取ります。

::

     bin/traffic_line -command argument

``traffic_line`` のコマンドのリストを見るにはこのように実行してください。

::

     bin/traffic_line -h

次のことに注意してください。
``traffic_line`` は管理者にとっては十分なツールである一方で、自動化のためには貧弱な選択です。
とくに監視については。
正しく監視する方法については `Monitoring Traffic <../monitoring-traffic>`_
の章を参照してください。

Stop Traffic Server
===================

Traffic Server を停止するには常に ``trafficserver`` コマンドに ``stop`` を渡します。
このコマンドは全ての Traffic Server プロセス
( ``traffic_manager``, ``traffic_server``, ``traffic_cop`` )
を停止します。
手動で各プロセスを止めないでください。予想できない結果を招きます。

::

    bin/trafficserver stop
