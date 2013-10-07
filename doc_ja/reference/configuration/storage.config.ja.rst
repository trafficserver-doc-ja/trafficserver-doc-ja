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

==============
storage.config
==============

.. configfile:: storage.config

:file:`storage.config` ファイルは、Traffic Serverのキャッシュとして
構成する全てのファイル、ディレクトリやハードディスク
パーティションを列挙します。
:file:`storage.config` ファイル修正後は、Traffic Server を
再起動しなければいけません。

Format 
======

:file:`storage.config` ファイルのフォーマットは::

    pathname size volume=volume_number

``pathname``  にはパーティションやディレクトリ、ファイルの名前を記述します。
``size`` には名前を付けたパーティション、ディレクトリやファイルのサイズを
(バイト単位で)指定します。
``volume``  には :file:`volume.config` と :file:`hosting.config` で使用されている
ボリューム番号を指定します。
ディレクトリやファイルはサイズを指定しなければいけません。
ローパーティションについては任意です。
``volume`` は任意です。

どんなサイズのどんなパーティションでも使用する事が出来ます。
最適な性能のためには以下のようにします:

- ローディスクパーティションを使用する
- 各ディスクで、全パーティションを同じサイズになるように作成する
- 各ノードで、全ディスクのパーティションを数が同じになるように作成する
- 似たような種類のストレージを、別ボリュームにグループ化する
  例えば、SSDやRAMドライブは独自のボリュームに分割する

オペレーティングシステム要求により、pathnames を指定してください。
以下の例を確認してください。
:file:`storage.config` ファイルには、フォーマット済みもしくはローディスクを、
少なくとも 128MB 指定します。

ローディスクやローパーティションを使う場合、Traffic Server プロセス に使用される
:ts:cv:`Traffic Server ユーザ <proxy.config.admin.user_id>` が、ローディスク
デバイスやローパーティションの読み書きの権限を持っているか確認するべきです。
ベストプラクティスの一つは、 デバイスファイルに 'g+rw' 権限が付与されることと
Traffic Server ユーザ がでバイスファイルの自身のグループに属していることを
確認することです。
しかしながら、幾つかのオペレーティングシステムではより強い要求があります。
更なる情報については、以下の例を確認してください。

標準的な ``records.config`` の数値と同様、ヒューマンリーダブルなプレフィックスも
サポートされています。
これらには以下のものを含みます。

  - ``K`` キロバイト (1024 バイト)
  - ``M`` メガバイト (1024^2 または 1,048,576 バイト)
  - ``G`` ギガバイト (1024^3 または 1,073,741,824 バイト)
  - ``T`` テラバイト (1024^4 または 1,099,511,627,776 バイト)

Examples
========

以下に、キャッシュストレージとして ``/big_dir`` ディレクトリで、
128MB 使用する例を示します。::

    /big_dir 134217728

``.`` シンボルを使用してカレントディレクトリを用いることもできます。
以下に、カレントディレクトリで 64MB キャッシュストレージを構築する例を示します。::

    . 134217728

代わりとして、ヒューマンリーダブルなプレフィックスを使用し、 64GB ファイルキャッシュを
表現できます::

   /really_big_dir 64G

.. note::
    ファイルシステム上のキャッシュディスクストレージを使用する際、
    指定されたディレクトリを一つのみ持てます。
    これは将来のバージョンで対応される予定です。 

Solaris Example
---------------

以下の例は、Solaris オペレーティングシステム用のものです。::

    /dev/rdsk/c0t0d0s5
    /dev/rdsk/c0t0d1s5


.. note:: サイズはオプションです。
          指定されなかった場合、パーティション全体が使用されます。

Linux Example
-------------

以下の例では、Linux オペレーティングシステムにおいて
ローディスクを使用します。::

    /dev/sde volume=1
    /dev/sdf volume=2

:program:`traffic_server` がこのディスクへアクセス可能なことを確実にするために、
:manpage:`udev(7)` を使って永続的に適切なパーミッションを設定することができます。
以下のルールはUbuntuをターゲットにされており、 
``/etc/udev/rules.d/51-cache-disk.rules`` に保存されます::

    # Assign /dev/sde and /dev/sdf to the www group
    # make the assignment final, no later changes allowed to the group!
    SUBSYSTEM=="block", KERNEL=="sd[ef]", GROUP:="www"

FreeBSD Example
---------------

5.1 FreeBSD から、明示的なローデバイスのサポートは終了しました。
FreeBSDにおいて全デバイスは、現在、生でアクセス可能です。

以下の例では、FreeBSD オペレーティングシステムで
ローディスク全体を使用します。::

    /dev/ada1
    /dev/ada2

:program:`traffic_server` がこのディスクへアクセス可能なことを確実にするために、
:manpage:`devfs(8)` を使って永続的に適切なパーミッションを設定することができます。
以下のルールは、 :manpage:`devfs.conf(5)` に保存されます。 ::

    # Assign /dev/ada1 and /dev/ada2 to the tserver user
    own    ada[12]  tserver:tserver

