# QRgen

QR コードを読み取り・作る Android アプリ（Flutter）。

- **読み取り**: カメラで読む。写真から読む（ギャラリーの画像を選ぶ）。読んだ内容はコピーするか、URL ならブラウザで開く
- **作成**: 文字を入れると QR コードを作る。誤り訂正の段（L / M / Q / H）を選べる。文字のコピーと、画像の保存（端末の「写真」の QRgen アルバムへ）ができる
- **履歴**: 読み取りと作成のそれぞれで、最近使ったものを端末の中に残す（外へは送らない）
- **設定**: 明るい・暗い・端末に合わせる、の表示の切り替え

ネットワークは使わない（release の版は INTERNET 権限を持たない）。

## 開発

- Flutter は CI の台（`.forgejo/workflows/test.yml` の `ci-flutter` の digest）に合わせる
- 試験: `flutter test`（PR と main への push で CI が流す）
- pubspec の `name` は雛形のまま `flutterbase`、applicationId は `com.nolumia.qrcorebasic`
- 開発用のビルドでは Debug Mode（ログ・デバッグ情報のメニュー）が最初から入る。release では切れていて、About の版を 7 回たたくと入る

## 配布

main へのマージで `.forgejo/workflows/version_bump.yml` が版を上げ、forge の push の知らせで deck が
ビルド・署名して share.nolumia.com へ配る（配ってよいアプリの一覧は deploy-repo の
`resources/flutter-apps.json`）。
