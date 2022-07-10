# ISUCON
公式の過去問レポジトリ
[isucon](https://github.com/isucon)


過去問の実行環境を整えたいならここのvagrantとansibleを使うと便利
[matsuu/vagrant-isucon](https://github.com/matsuu/vagrant-isucon)

## 問題を解く
各種言語で実装されたウェブアプリケーションがMySQLをデータベースとしてシングルインスタンスで動いているので、そこに大量のリクエストが来たときに上手にさばけるように改造する。
ただし、レスポンスの内容は基本的に一字一句変更できない（例えばJavascriptファイルをminimizeして、たとえ表示内容が変わらなくてもNG）（クッキーの中身とかはOK）。
### まずやること
大会が始まったらまずやること

- ルールをよく読む
  - 解法を探るためのヒントが落ちていることがある
  - こういう場合はこういうレスポンスを返しても良い、というルールをうまく活用することでスコアが伸びることもある
  - スコアの方式は毎年微妙に変わったりするので要注意
  - 再起動試験などの手順はよく確認しないと最悪の場合失格になる
- 問題プログラムを共有する
  - サーバー上に置いてあるプログラムファイルをローカルに持ってきて、Githubなどでチームメイトと共有する
  - シングルファイルで構成されているので、エンドポイント毎にモジュール分割するとコンフリクトが少なくいいかも
  - 使わない言語の実装は適宜取り除くといいかもしれないが、移植時のバグの可能性を考えてGo言語のものはリファレンスとして残しておいてもいいかも
- サーバーの構成を調べる
  - CPUの数、メモリ、ディスク容量、使われているDBなど
  - 年によってはサーバーごとにメモリやCPU数が違ったりするので注意
- ボトルネックを探る
  - アクセスログや実装を見てあげることでどこがボトルネックかを分析することでどこに高速化できる余地があるかを探すのがまず第一
  - 言語のプロファイラ、アクセスログをalpで解析する、pt-query-digestでSQLのスロークエリを探す、など


### 解法の方針
高速化するにはだいたい以下のようなことをしていくと良い。

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
  - テーブルに新たなGenerated columnを追加することでクエリが最適化できることも
  - データベース以外にも外部APIの通信がある年もある。こちらも呼び出し回数の最小化、並列化などで最適化できる場合がある
  - Redisなどの異なるデータベースを使えば高速化できる可能性がさらに広がる、が実装は複雑になる
- ユーザー認証
  - bcryptによる暗号化は遅いのでストレッチング回数を減らすこと、そもそもアルゴリズムを変えてしまうことにより高速化が可能
  - この部分はISUCON9の予選で判定が紛糾したこともあるので、変更不可となるかもしれない
- 初期実装にバグがあることもある
  - 特にGo言語以外だとバグっている可能性は高くなる。過信は禁物。
  - 部分的に改良しある程度高速化が進むと顕在化する

### 開発の仕方
この辺は個人の好みの問題もあるのでチーム内で要相談

短時間の開発で、変更が容易に反映されることを目指した方針

- ウェブアプリのデプロイはrsync等でコンパイル済みのものをアップロードする
  - サーバーは貧弱でコンパイル時間が長くなることも
  - Windows・Macユーザーの場合、ちゃんとサーバー上で実行できるLinux用バイナリが吐けるか要確認
  - Gitレポジトリを経由する・CIを使うとかは時間が限られたコンテストの障害になるので避ける
  - サーバー毎に変えたい設定は環境変数経由でコントロールする
      - systemdの`EnvironmentFile`が例年だと設定されているので、それを使うと便利
- `/etc`以下の設定ファイルはetckeeperに任せ、リモートのGitレポジトリは経由させない
  - リモート経由だとパーミッション設定とかで面倒なことになる
  - サーバーごとに微妙に設定を変えたい場合も困る
- サーバー上のDBの状態を確認したい時はSSHトンネリングを使うと便利
  - `ssh -fNL <local port>:localhost:<DB port> <remote-addr>`
- ベンチマークを走らせる前の処理・後の処理はシェルスクリプト化するなどして自動化するとよい

## 準備しておきたいこと
例年の傾向からおさえておきたい知識

### mysql
大体、mysqlの[N+1問題](https://www.techscore.com/blog/2012/12/25/rails%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E7%B4%B9%E4%BB%8B-n1%E5%95%8F%E9%A1%8C%E3%82%92%E6%A4%9C%E5%87%BA%E3%81%99%E3%82%8B%E3%80%8Cbullet%E3%80%8D/)を潰すのが大きな仕事だったりするので、mysqlの文法はきちんと勉強しておくといい
- [チートシート](https://www.mysqltutorial.org/mysql-cheat-sheet.aspx)

チューニングはまずはスロークエリのしきい値を0にしてしまってから[pt-query-digest](https://www.percona.com/software/database-tools/percona-toolkit)で解析してあげると、どのクエリが頻繁に呼ばれているか、どこを集中的にチューニングするべきかがわかる。
参考：[スローログの集計に便利な「pt-query-digest」を使ってみよう](https://thinkit.co.jp/article/9617)

Rows sentがRow examineに対して大きすぎる場合、indexを貼り直すことを検討する。複合インデックスを用意しておいた場合でも`FORCE INDEX`句を付けないとちゃんときかないこともあるので`EXPLAIN`句でどのインデックスが実際に使われているか確認する。
参考：[オトコのソートテクニック2008](http://nippondanji.blogspot.com/2008/12/2008.html)

さらなるチューニング（クエリキャッシュのサイズなど）は[MySQLTuner](https://github.com/major/MySQLTuner-perl)を使って何が悪いかを突き止めるといいかも？
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

## 便利そうだが自分は使ったことのないもの

### Varnish
[公式ドキュメント](https://varnish-cache.org/docs/index.html)

キャッシュ機能を持つリバースプロキシとして使える。nginxとウェブアプリの間に挟むことでレスポンスを手軽にキャッシュできるらしい。
変更がないデータ以外にも、更新にタイムラグが許されているエンドポイントに使うとかの技がある。

### Redis
[公式ドキュメント](https://redis.io/documentation)

Key-Value型のインメモリデータベース。データベースの一部カラムをRedisで管理することで高速化できたりするはずだが、大抵変更量が多くて下手に手を出してもうまくいかないことが多いように思える（個人の感想）。
使うつもりなら事前練習をしっかり積んだほうがいい。

### Proxy SQL
[公式ドキュメント](https://proxysql.com/documentation/)

MySQL 8以降だとクエリキャッシュが効かない。かわりにProxySQLをかますなどでキャッシュできる。
が、本来の用途は冗長化とかにあるっぽいので、果たして有効な手段かわからない。


## 過去の講評とか
- [ISUCON9 まとめ](http://isucon.net/archives/53570241.html)
- [ISUCON11 まとめ](https://isucon.net/archives/55821036.html)
