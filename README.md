# trafficserver-doc-ja

Apache Traffic Server のドキュメントを日本語に翻訳するプロジェクトです。

## オリジナルサイト／リポジトリ

- ドキュメント : http://trafficserver.apache.org/docs/
- リポジトリ : https://github.com/apache/trafficserver/tree/master/doc

# 翻訳
## Work in progress

- [Index](./doc_ja/index.ja.rst)
- [Administrator's Guide](./doc_ja/admin/index.ja.rst) Installing, configuring and administrating Traffic Server

## Not yet

- [SDK Programmer's Guide] Developing Traffic Server plug-ins and how the code works
- [Frequently Asked Questions] A running list of your most common questions

# Contribution

このプロジェクトに参加するいくつかの方法を紹介します。
いずれの方法でも歓迎しますので、気軽にご参加ください。

1. GitHub 上で翻訳/校正を行う方法
3. Transifex 上で翻訳/校正を行う方法

## GitHub

日本語訳の追加／修正等の Pull-Request を送ってください。

### 新規に翻訳を始める場合

1. このリポジトリを Fork してください。
2. Issue にどのドキュメントを翻訳するか登録してください。
   これは同じドキュメントに対して複数の方が同時に翻訳作業を行うことを防ぐためです。
3. 翻訳をしてください。
   ディレクトリ構成は apache/trafficserver に従ってください。
   ファイル名を `***_ja.rst` としてください。
4. `master` ブランチへ Pull-Request を送ってください。

### レビューする場合

登録されている Pull-Request を読んでいただいて、コメントをお願いします。

## Transifex

Apache Traffic Server のドキュメントの各言語への翻訳プロジェクトが [Transifex](https://www.transifex.com/) というウェブサービス上にあります。
コミッターの James Peach さんが管理されています。現在、全てのドキュメントがここにあるわけではありません。(2013/10/06 現在)
校正作業は Transifex 上で行った方が楽なので、将来的に校正作業はこちらに移していきたいと考えています。

Transifex へサインアップして、 Apache Traffic Server の日本語翻訳チームに参加してください。OSS 利用であれば無料で登録することができます。

Transifex への参加は"翻訳者"と"レビューワー"という２つの方法があります。

- 翻訳者 : 翻訳作業をする方
- レビュワー : 翻訳を確認／校正する方

翻訳者／レビュワーどちらでも歓迎いたします。気軽にご参加ください。

- [Transifex](https://www.transifex.com/)
- [Apache Traffic Server @Transifex](https://www.transifex.com/projects/p/traffic-server-admin/)
- [Apache Traffic Server @Transifex Japanese Team](https://www.transifex.com/projects/p/traffic-server-admin/language/ja_JP/)

## License

trafficserver-doc-ja プロジェクトの成果物は著作権およびライセンスによる制限のない限り、
翻訳著作権はこれを trafficserver-doc-ja に帰属することとし、Apache Traffic Server と同じ
Apache License Version 2 下に公開するものとします。

詳しくは下記を参照してください。

- https://github.com/apache/trafficserver/blob/master/LICENSE


翻訳者の方々には翻訳著作権を当プロジェクトに寄贈していただく事になりますが、
これは翻訳元ドキュメントのライセンス変更に対応したり、あるいは第三者によるライセンス侵犯に対処するための必要な処置です。
翻訳したドキュメントの自由で円滑な更新・配布を可能とするため、ご理解とご協力をお願いいたします。

- Owners は有償のサービスや書籍として成果物を公開することがあります。
- 訳文の提出者が明らかなときは、断りのない限り、貢献者としてお名前や id を明記することがあります。
- Apache Traffic Server プロジェクトや他のプロジェクトに成果物を寄付することがあります。
