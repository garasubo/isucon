# ISUCON
公式の過去問レポジトリ
[isucon](https://github.com/isucon)


過去問の実行環境を整えたいならここにvagrantとansibleを使うと便利
[matsuu/vagrant-isucon](https://github.com/matsuu/vagrant-isucon)

## テクニック

### mysql
大体、mysqlの[N+1問題](https://www.techscore.com/blog/2012/12/25/rails%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E7%B4%B9%E4%BB%8B-n1%E5%95%8F%E9%A1%8C%E3%82%92%E6%A4%9C%E5%87%BA%E3%81%99%E3%82%8B%E3%80%8Cbullet%E3%80%8D/)を潰すのが大きな仕事だったりするので、mysqlの文法はきちんと勉強しておくといい
- [チートシート](https://www.mysqltutorial.org/mysql-cheat-sheet.aspx)

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
