Plugin Reference
****************

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

概要
====

Apache Traffic Server の重要な機能の一つはモジュール性です。
コアに不要な機能はコアの中には存在しません。
これは良いことです。なぜならば、それはコアがいつでも提供する
キャッシュとプロキシーに集中することにより、速い状態を保つこと
ができるからです。

All other things can be moved into plugins, by opening up a consistent
C API, everyone can implement their own functionality, without
having to touch the core.

他のことはプラグインに移すことができます。

Stable plugins
==============

Plugins that are considered stable are installed by default in
Apache Traffic Server releases.

.. toctree::
  :maxdepth: 1

  cacheurl.en
  conf_remap.en
  gzip.en
  header_filter.en
  regex_remap.en
  stats_over_http.en

Experimental plugins
====================

Plugins that are considered experimental are located in the
```plugins/experimental`` <https://git-wip-us.apache.org/repos/asf?p=trafficserver.git;a=tree;f=plugins/experimental;hb=HEAD>`_
directory in the Apache Traffic Server source tree. Exmperimental plugins can be compiled by passing the
`--enable-experimental-plugins` option to `configure`::

    $ autoconf -i
    $ ./configure --enable-experimental-plugins
    $ make

.. toctree::
  :maxdepth: 1

  balancer.en
  buffer_upload.en
  cacheurl.en
  combo_handler.en
  esi.en
  geoip_acl.en
  hipes.en
  metafilter.en
  mysql_remap.en
  stale_while_revalidate.en
