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
マークアップする全てのファイル、ディレクトリやハードディスク
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

ローディスクやローパーティションを使う場合、traffic_server を動かす
管理ユーザが、読み書きの権限を持っているか確認するべきです。
管理ユーザ ID は、```proxy.config.admin.user_id`` <records.config#proxy.config.admin.user_id>`_. で設定します。
ベストプラクティスの一つとして、 g+rw 権限がディスクに付与されている場合、
管理ユーザ ID をそのグループに属させて権限を与えることがあります。
しかしながら、幾つかのオペレーティングシステムでは奇妙な要求があります。
更なる情報については、以下の例を確認してください。

標準的な ``records.config`` の数値と同様、人間が読める接頭辞もサポートされています。
これらには以下のものを含みます。

  - ``K`` キロバイト (1024 バイト)
  - ``M`` メガバイト (1024^2 または 1,048,576 バイト)
  - ``G`` ギガバイト (1024^3 または 1,073,741,824 バイト)
  - ``T`` テラバイト (1024^4 または 1,099,511,627,776 バイト)

Examples
========

以下に、キャッシュストレージとして ``/big_dir`` ディレクトリで、
64MB 使用する例を示します。::

    /big_dir 67108864

``.`` シンボルを使用してカレントディレクトリを用いることもできます。
以下に、カレントディレクトリで 64MB キャッシュストレージを構築する例を示します。::

    . 67108864


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

``traffic_server`` がディスクにアクセスする為に、 
``udev`` を使って適切なパーミッションを設定します。
以下のルールはUbuntuをターゲットにしたものであり、 
``/etc/udev/rules.d/51-cache-disk.rules`` に保存します::

    # Assign /dev/sde and /dev/sdf to the www group
    # make the assignment final, no later changes allowed to the group!
    SUBSYSTEM=="block", KERNEL=="sd[ef]", GROUP:="www"

FreeBSD Example ## {#LinuxExample}
----------------------------------

5.1 FreeBSD から、明示的なローデバイスのサポートは終了しました。
FreeBSDにおいて全デバイスは、現在、生でアクセス可能です。

以下の例では、FreeBSD オペレーティングシステムで
ローディスク全体を使用します。::

    /dev/ada1
    /dev/ada2

``traffic_server`` でディスクにアクセスする為に、 ``devfs`` を使って
適切なパーミッションを設定します。
以下のルールを、 ``/etc/devfs.conf`` に保存します。 ::

    # Assign /dev/ada1 and /dev/ada2 to the tserver user
    own    ada[12]  tserver:tserver

