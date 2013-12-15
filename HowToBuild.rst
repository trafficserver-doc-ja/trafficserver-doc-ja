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

ローカル環境で RTD テーマの使用
==============================

* https://github.com/snide/sphinx_rtd_theme

参考
====

* http://docs.sphinx-users.jp/intl.html
* http://read-the-docs.readthedocs.org/en/latest/faq.html#i-want-to-use-the-read-the-docs-theme-locally
