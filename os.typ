#pagebreak()
= OSのインストール
== Whitebox Switchの入り方
まずWhitebox Switchの入り方を記す。
tera term等を使い、シリアル通信により直接Whitebox Switchに接続する。
ssh接続でもいいが、後に説明するSDE環境構築といった長時間のビルドの際には適さなない。
ssh接続が自動で途絶えてしまう可能性ある(経験談)。
Whitebox Switchに入ると以下のようにユーザ名、パスワードを問われる。
#show raw: set text(size:1.2em)
```
bmc login: root
Password: 0penBmc (アルファベットのOではなく、数字の0)
```
以上により、Whitebox Switchに入れる。

== OSのインストールの仕方
今回使うネットワークOS(NOS)として、Open Network Linux(ONL)とSONiCがメジャーである。まずOpen Netowork Linuxは、NOSの代表であるが、公式は今はサポートしていないため、多くのONL関連のサイトのリンクは切れていることが多い(特にgithub)。またONLインストール用のbinファイルは存在するが、SDE環境構築の際のカーネルヘッダがない。次にSONiCは今でもサポートはされているが、Debian11をベースにしたOSしかなく、SDEの推奨OS(Debian8,9,10)を満たさない。しかしSONiCに関しては、カーネルヘッダがある。ここで実際にOSのインストール方法を記す。以下のshellを打つことでWBS内のOSに入ることができる。
```
root@bmc:~# sol.sh
```
Dual Bootになっており、NOSとONIEというOSが入っているが、ONIEはNOSをインストールするための環境だと思えば良い。実際にONIEを選択すると、
```
ONIE:/ #
```
以上のようなターミナルが開き、立て続けに多くのログが吐かれる。そこで以下のコマンドを打つとログの出力がなくなる。
```
ONIE:/ # onie-stop
```
== USBを使ったOSのインストール方法
サイトで探すとどれもwgetを使ったOSインストールファイルのダウンロードを推奨しているが、前述したようにリンク切れが多いため、厳しい。そこでOSインストール用のバイナリファイルを各OS名のディレクトリに配布する。

=== SONiC
SONiCはDebianをベースとして作られている。筆者は今回Debian10を用いた。OSのイメージファイル(bin)とカーネルヘッダ(deb)はSONiC Image Azure Pipelines\@sonic_image から入手した。それらをusbにコピーし、WBSに接続する。次にターミナル上でusbをマウントする。
```
ONIE:/ # onie-nos-install sonic-barefoot.bin
```
以上のようなコマンドでOSをインストールできる。注意点として、バイナリファイルは一度、/tmp等に移動し、USBをアンマウントを行わないとインストールに失敗する。インストールに成功するとログイン画面が表示されるため、以下のように入力する。
```
Debian GNU/Linux 10 sonic ttyS0

sonic login: admin
Password: YourPaSsWoRd
```
以上がSONiC OSのインストールの手順である。またカーネルヘッダのインストールに関しては、

#figure(caption: [SONiC起動画面])[
  #image("image/SONiC.png")
]
```
sudo apt-get update
sudo apt-get install linux-headers-$(uname -r)
```
以上のような形を推奨されるが、SONiCを含むNOSのカーネルはaptで見つけることができない。
そのため、先程のheadersディレクトリの中にあるdebファイルを用いる。
```
admin@sonic:~$ sudo dpkg -i linux-headers-4.19.0-12-2-common_4.19.152-1_all.deb
admin@sonic:~$ sudo dpkg -i linux-headers-4.19.0-12-2-amd64_4.19.152-1_amd64.deb
```
以上の形でパッケージをインストールすればよいが、2つ目のパッケージのインストールするにはkbuildとcompiler-gcc-8が必要とエラーが吐かれる。両者ともdebパッケージを探してインストールすればよい。またsudo apt-get updateをすると認証がどうのこうのと言われる。そのため、/etc/apt/source.listに以下を書き込む。
```
deb http://debian-archive.trafficmanager.net/debian buster main
deb http://debian-archive.trafficmanager.net/debian-security buster/updates main
deb http://debian-archive.trafficmanager.net/debian buster-backports main
```
また/etc/apt/sources.list.d/debian_archive_trafficmanager_net_debian.listを削除すると実行できるようになる。筆者の知識不足故理由は不明。

\ #text(15pt)[注意事項] \  \

- バイナリファイルによってインストールしたOSを以下のようにアップグレードするとOSが壊れ、reboot時に立ち上げられなくなる(実証済み)。
```
sudo apt-get upgrade
```
- Debian10では最新のパッケージをインストールすると依存関係でエラーがでることが多いため、少しバージョンを下げることをおすすめする。

- 依存ライブラリ等をインストールする際に、何かしらの依存関係でエラーが出る場合、以下のように未解決パッケージを修復するとうまくいくことがある。
```
sudo apt --fix-broken install

```