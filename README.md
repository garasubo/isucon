# ISUCON
公式の過去問レポジトリ
[isucon](https://github.com/isucon)


過去問の実行環境を整えたいならここのvagrantとansibleを使うと便利
[matsuu/vagrant-isucon](https://github.com/matsuu/vagrant-isucon)

## テクニック
### 予選の大まかな方針
各種言語で実装されたウェブアプリケーションがMySQLをデータベースとしてシングルインスタンスで動いているので、そこに大量のリクエストが来たときに上手にさばけるように改造する。
ただし、レスポンスの内容は基本的に一字一句変更できない（例えばJavascriptファイルをminimizeして、たとえ表示内容が変わらなくてもNG）（クッキーの中身とかはOK）。
高速化するにはだいたい以下のようなことをしていくと良い。

- ボトルネックを探る
  - アクセスログや実装を見てあげることでどこがボトルネックかを分析することでどこに高速化できる余地があるかを探すのがまず第一
- マルチインスタンス化
  - そのままサーバーを複数立てるだけでは当然駄目なので工夫が必要。
  - ちゃんとロードバランスする以外にもエンドポイント毎に役割を分ける、静的ファイル配信専用サーバーをつくる、など
  - 場合によっては変にマルチインスタンス化するよりもシングルインスタンスの性能を詰めてしまったほうが速い、ということもある
- チューニング
  - nginxやmysqldの設定をいじることでパフォーマンスが向上する
  - どこが遅い原因かを考えながら設定する
- データベースとの通信の最適化
  - N+1問題の解決、必要なカラムのみをとってくるようにする、など
  - 不変なデータが置かれている場合もあるので、そういう場合はメモリに載せてしまう、プログラムに埋め込んでしまうなどの工夫をする
  - Redisなどの異なるデータベースを使えば高速化できる可能性がさらに広がる、が実装は複雑になる
- ユーザー認証
  - bcryptによる暗号化は遅いのでストレッチング回数を減らすこと、そもそもアルゴリズムを変えてしまうことにより高速化が可能
  - この部分はISUCON9の予選で判定が紛糾したこともあるので、変更不可となるかもしれない
- ルールをよく読むとヒントがあることも
  - こういう場合はこういうレスポンスを返しても良い、というルールをうまく活用することでスコアが伸びることもある
- 初期実装にバグがあることもある
  - 特にGo言語以外だとバグっている可能性は高くなる。過信は禁物。
  - 部分的に改良しある程度高速化が進むと顕在化する

### mysql
大体、mysqlの[N+1問題](https://www.techscore.com/blog/2012/12/25/rails%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E7%B4%B9%E4%BB%8B-n1%E5%95%8F%E9%A1%8C%E3%82%92%E6%A4%9C%E5%87%BA%E3%81%99%E3%82%8B%E3%80%8Cbullet%E3%80%8D/)を潰すのが大きな仕事だったりするので、mysqlの文法はきちんと勉強しておくといい
- [チートシート](https://www.mysqltutorial.org/mysql-cheat-sheet.aspx)

チューニングはスロークエリの監視及び[MySQLTuner](https://github.com/major/MySQLTuner-perl)を使って何が悪いかを突き止めるといいかも？
参考：[MySQLデータベースのパフォーマンスチューニング](https://qiita.com/mm-Genqiita/items/3ef91f6df6c15c620ec6)

### ansible
このレポジトリの下に過去に自分が使ったansibleが置かれている。コンテスト開始直後にとりあえず走らせるというのができると気が楽なのでおすすめ。複数サーバーに対しても走らせられるし。
よく使うコマンドのインストールや簡易版のvimrc以外にやっていることとしては

- `/etc`以下のファイルをgitで管理するための[etckeeper](https://wiki.archlinux.jp/index.php/Etckeeper)の導入
- CPU使用率やネットワークの使用率などをリアルタイムに監視できるウェブインターフェースを提供する[netdata](https://github.com/netdata/netdata)の導入-
- まれにボットアタックを受けることによってパフォーマンスが低下するケースがあるので[denyhosts](http://denyhosts.sourceforge.net/)を導入する
  - ブラックリスト形式なのであんまりいい方法ではないかも。[sshguard](https://wiki.archlinux.jp/index.php/Sshguard)とかのほうが現代的？



### nginxのアクセスログからボトルネックを探る
[alp](https://github.com/tkuchiki/alp)というのがISUCONではよく使われる。

アクセスログを特定のフォーマットにすればnginx以外でも利用可能(ISUCON8で使われたH2Oとか)

### nginxのチューニングやテクニック
- [公式ドキュメント](https://nginx.org/en/docs/)
- [nginxパフォーマンスチューニング〜静的コンテンツ配信編〜](https://qiita.com/cubicdaiya/items/2763ba2240476ab1d9dd)
- 静的ファイルをアップロード＆ダウンロードを複数サーバーでやるには`try_files`が便利そう。参考: [nginx serve from static if not found try reverse proxy](https://stackoverflow.com/questions/28572392/nginx-serve-from-static-if-not-found-try-reverse-proxy/28578419)



## 過去の講評とか
[ISUCON9 まとめ](http://isucon.net/archives/53570241.html)
