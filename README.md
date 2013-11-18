# trafficserver-doc-ja

Apache Traffic Server のドキュメントを日本語に翻訳するプロジェクトです。

※作業リポジトリは [trafficserver-doc-ja/trafficserve](https://github.com/trafficserver-doc-ja/trafficserver/tree/doc-ja/doc) です。

## オリジナルサイト／リポジトリ

- ドキュメント : https://trafficserver.readthedocs.org/en/latest/
- リポジトリ : https://github.com/apache/trafficserver/tree/master/doc

## 日本語翻訳版

- ドキュメント : https://trafficserver.readthedocs.org/ja/latest/
- リポジトリ : https://github.com/trafficserver-doc-ja/trafficserver/tree/doc-ja/doc

# Contribution

このプロジェクトに参加するいくつかの方法を紹介します。
いずれの方法でも歓迎しますので、気軽にご参加ください。

1. GitHub 上で翻訳/校正を行う方法
2. Transifex 上で翻訳/校正を行う方法(現在はトライアル状態です)

## GitHub

日本語訳の追加／修正等の Pull-Request を送ってください。

### 新規に翻訳を始める場合

1. [trafficserver-doc-ja/trafficserver](https://github.com/trafficserver-doc-ja/trafficserver) を Fork してください。
2. どのドキュメントを翻訳するか決めてください。
   [doc/locale/ja/LC_MESSAGES/](https://github.com/trafficserver-doc-ja/trafficserver/tree/doc-ja/doc/locale/ja/LC_MESSAGES) 下に
   PO ファイルが用意してあります。
   PO ファイルについては下記等を参照してください。
   - http://www.postgresql.jp/document/9.2/html/nls-translator.html
3. タイトルに "[WIP]" プレフィックスをつけて `doc-ja`  ブランチに  Pull-Request を投げてください。
   これは同じドキュメントに対して複数の方が同時に翻訳作業を行うことを防ぐためです。
   
   例えば `admin/http-proxy-caching` を翻訳するのであれば、` [WIP] Translate admin/http-proxy-caching` のようなタイトルになります。
4. `doc/locale/ja/LC_MESSAGES/` ディレクトリしたの `*.po`ファイルを翻訳してください。 
5. 翻訳が完了したら "[WIP]" プレフィックスを取って、マージしても問題ないことを示してください。

### 翻訳を修正する場合

新規に翻訳を始める際と同様に Pull-Request を投げてください。

### レビューする場合

登録されている Pull-Request を読んでいただいて、コメントをお願いします。
"[WIP]" プレフィックスが付いているものでも、翻訳者に早くフィードバックするためにコメントをお願いします。

### 原文に typo を発見した場合

翻訳中に原文の typo を発見した場合は、typo のみを修正して `typos` ブランチに Pull-Request を投げてください。
これは翻訳の完了を待たずに修正を速やかに本家に報告することを可能にし、本家でマージを行う際に確認作業を行いやすくするためです。

## Transifex

Apache Traffic Server のドキュメントの各言語への翻訳プロジェクトが [Transifex](https://www.transifex.com/) というウェブサービス上にあります。
校正作業は Transifex 上で行った方が楽なので、将来的に校正作業はこちらに移していきたいと考えています。

Transifex へサインアップして、 Apache Traffic Server の日本語翻訳チームに参加してください。
OSS 利用であれば無料で登録することができます。
チームに参加後、Transifex 上で翻訳されるか、既に翻訳してあるものに対してコメントをください。
特に承認等のプロセスはございませんので、気軽にご参加ください。

- [Transifex](https://www.transifex.com/)
- [Apache Traffic Server @Transifex](https://www.transifex.com/projects/p/traffic-server-admin/)
- [Apache Traffic Server @Transifex Japanese Team](https://www.transifex.com/projects/p/traffic-server-admin/language/ja_JP/)

# 用語

翻訳・レビューの際に用語が問題になることが多いです。いくつかの用語は Transifex 上の用語集にまとめています。
参考にしてください。

- [Apache Traffic Server / 用語集 / Japanese (Japan) ja_JP](https://www.transifex.com/projects/p/traffic-server-admin/glossary/l/ja_JP/)

追加・変更・コメントなどをいただけると幸いです。
Transifex 上でも、GitHub 上で Issue を登録していただいても結構です。

# License

trafficserver-doc-ja プロジェクトの成果物は著作権およびライセンスによる制限のない限り、
翻訳著作権はこれを trafficserver-doc-ja に帰属することとし、Apache Traffic Server と同じ
Apache License Version 2 下に公開するものとします。
また、最終的に Apache Traffic Server コミュニティに成果物を寄付します。

詳しくは下記を参照してください。

- https://github.com/apache/trafficserver/blob/master/LICENSE

翻訳者の方々には翻訳著作権を当プロジェクトに寄贈していただく事になりますが、
これは翻訳元ドキュメントのライセンス変更に対応したり、あるいは第三者によるライセンス侵犯に対処するための必要な処置です。
翻訳したドキュメントの自由で円滑な更新・配布を可能とするため、ご理解とご協力をお願いいたします。

- Owners は有償のサービスや書籍として成果物を公開することがあります。
- 訳文の提出者が明らかなときは、断りのない限り貢献者としてお名前や id を明記することがあります。
- 他のオープンソースプロジェクトに寄付することがあります。
- Apache Traffic Server プロジェクトに成果物を寄付します。
