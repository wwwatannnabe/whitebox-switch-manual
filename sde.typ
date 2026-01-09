#pagebreak()
= SDE-8.2.2のビルド
この章ではSDEの環境構築の手順を踏むが、これはbf-sde-8.2.2/READMEを参考にしている。他のバージョンのSDEを使う場合、手順が全く異なるため注意しなければならない。READMEを参考にしてほしい。

==　全体の流れ
#import table: cell, header

#table(
  columns: 2,
  align: center,
  header(
    [*Stage*],
    [*Content*],
  ),
  [P0],[前準備],
  [P1],[バイナリパッケージのインストール],
  [P2],[bf-syslibsのインストール],
  [P3],[bf-utilsのインストール],
  [P4],[bf-driversのインストール],
  [P5],[switchのインストール],
  [p6],[bf-platformsのインストール],
  [P7],[p4-buildのインストール],
  [p8],[p4-exampleのインストール],
  [p9],[ptf-modulesのインストール],
  [p10],[bf-platformsのインストール]
)

== 前準備
SDE環境構築に必要な最低限のツールをインストールする。以下のコマンドを実行すればよい。設定としてbf-sde-x.x.xディレクトリをSDEに合わせる。
```
export SDE=/home/admin/8.2.x/bf-sde-8.2.2
$SDE/install_min_deps.sh
```
次にすべてのパッケージの解凍として以下のシェルを動かす。
```
./extract_all.sh
```
この際にSDEにディレクトリを指定しないとエラーが吐かれる。インストール先としては、installディレクトリを指定する。root権限でインストール先を指定してしまうと後々の依存関係で複雑になる(らしい)。
```
export SDE_INSTALL=$SDE/install
export PATH=$SDE_INSTALL/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$SDE_INSTALL/lib:$LD_LIBRARY_PATH
```
== 各ディレクトリによるビルドの前に
P2~P6に関しては全て似たようなコマンド実行のため、多少省略するが、随時各ディレクトリのREADMEを参照してほしい。また警告をエラー扱いされる場合がよくあるが、基本警告を無視してビルドしてかまわない。次のようにmakeする前にconfigを設定し、インストールする流れだが、./configureを実行する際に、つけたいオプションをつければよい。READMEと./configure --helpを参照してほしい。

== bf-syslibsのインストール
bf-driversを動かすために必要なライブラリのインストール用のディレクトリ。libbfsys.[a,la,so]等のファイルが生成されるはず。
```
./configure --prefix=$SDE_INSTALL
make -j$(nproc)
make install
```
== bf-utilsのインストール
Barefoot Networksに必要なライブラリのインストール用のディレクトリ。libbfutils.[a,la,so]等のファイルが生成されるはず。
```
./configure --prefix=$SDE_INSTALL
make -j$(nproc)
make install
```
== bf-driversのインストール
Tofino ASICを制御するためのドライバをインストールするためのディレクトリ。正しくインストールしているとbf\_[kdrv/kpkt/knet]\_mod\_[un]loadが\$SDE_INSTALL/install/binに生成されるはず。
```
./configure --prefix=$SDE_INSTALL
make -j$(nproc)
make install
```
picocライブラリがないとエラーが出力された場合、以下のようにディレクトリを指定するとうまくいくかもしれない。単にインストールされていないかもしれないため、確認してほしい。
```
export PYTHONPATH=$SDE/install/lib/python2.7/site-packages:$PYTHONPATH
```

== switchのインストール
標準のスイッチング機能のパイプラインを実装したp4プログラムのコンパイル用のディレクトリ。実際にinstallを始めるとコンパイルがとてつもなく遅いことが実感できる。正しくインストールできると./install/share/p4/targets/tofino/に.confファイルが生成される。
```
./install_switch_deb.sh
./configure --prefix=$SDE_INSTALL --with-switchapi --with-tofino
make -j$(nproc)
make install
```

== bf-platformsのインストール
このディレクトリは別のbf-reference-bsp-8.2.2からコピーしてくる。BFのSDEにプラットフォーム固有のポート管理の設定をインストールする。これがないと動かないらしい。正しくインストールできるとbf\_port\_mgmt等のファイルが生成される。
```
./configure --prefix=$SDE_INSTALL --with-tofino --with-tof-brgup-plat
make -j$(nproc)
make install
```
ここまでのビルドでrun_switchd.shは動くはずである。このあとのビルドに関してはただp4c-tofinoを使い、コンパイルするだけなので省略する。

== p4-buildのインストール
bf-platformsまで正しくビルドできているならば、\$SDE_INSTALL/bin/p4c-tofinoが生成されているはずである。これよりさきは、p4プログラムをコンパイルする方法であるそのため、p4c-tofinoさえ使えればこれ以上のビルドは必要ない。しかし、p4-buildでコンパイルすると./run_switchd.shを実行するのが簡単である。
```
export P4_NAME=<プログラム名>
export P4_PATH=<p4プログラムがある位置>
./configure --prefix=$SDE_INSTALL
make -j$(nproc)
make install
```


== p4-exampleのインストール
== ptf-moduilesのインストール

== エラー一覧
```
#inlcude <libio.h>
```
このライブラリがないとエラーを履かれた際はコメントアウトでインストールはできる。