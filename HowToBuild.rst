日本語に翻訳済みのドキュメントをローカル環境でビルドする時の最低限の手順についてまとめます。

必要パッケージ
==============

* sphinx
* gettext
* sphinx-intl

ビルド方法
==========

.po ファイルから .mo ファイルを生成する
---------------------------------------

::
  $ sphinx-intl build -p locale/ -l ja


.mo を用いつつドキュメントをビルドする
--------------------------------------

::
  $ sphinx-build -b html -D language=ja . ./build

参考
====

http://docs.sphinx-users.jp/intl.html
