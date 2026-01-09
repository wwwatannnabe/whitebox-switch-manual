#pagebreak()
= switchd
== 実際に動かす
下図に表すようにASICを直接触ることはできないため(筆者の知識不足)、Main CPU(NOSを起動してるCPU)を通じて間接的に制御する必要がある。制御の仕方としては、データプレーンを制御するためのプログラムであるP4プログラムをASICにロードする必要がある。

#figure(caption: [P4プログラムをロード])[
  #image("image/load.png",width: 60%)
]
\
先ほどのビルドを完了したら実際にASICにP4プログラムをロードし、動かしてみる。
正しくビルドできると次のようなログが吐かれ、bfshellが起動される。このbfshellというのはTofino ASIC用のコマンドラインインターフェース(CLI)で、ASIC上で動くP4パイプラインやテーブル操作等を行うツールである(っぽい)。

#pagebreak()
#figure(caption: [動作確認])[
  #image("image/switch.png",width: 100%)
]

== p4コンパイラ
ASICにロードするプログラムはP4言語で書かれるが、P4プログラムのコンパイラを説明する。コンパイルによって生成されるファイルは2つあり、tofino.binとcontext.jsonである。前者は実際にASICにロードするバイナリファイルであり、ASICを動かすためのファイルである。後者はテーブル情報
正しい構文で書かれたp4プログラムだと以下のようなログが出力される。
```
Parsing successful
Semantic checking successful
```

#pagebreak()
== P4プログラムの構成

#import "@preview/cetz:0.4.2": *
#canvas({
  import draw: *
  /*ファイルの位置づけ*/
  rect((-8,6), (rel: (5,5)),name: "switch")
  content((rel:(0,-0.5),to:"switch.south"),[switch.p4])
  content((rel:(0,0),to:"switch"),
  [
  入力パイプライン\
  control ingress{\
  　set\_A()\
  }\ \
  出力パイプライン\
  control egress{ ... }\
  ])

  rect((0,1), (rel: (8,10)),name: "l2")
  content((rel:(0,-0.5),to:"l2.south"),[l2.p4等])
  content((rel:(0,0),to:"l2"),
  [
  action set\_D(){\ 
  }\ \
  control set\_A(){\
  　apply(set\_B)  \
  }\ \
  table set\_B{\
    　reads{  -- -- -- -- --　ルックアップ\
    　　key: exact;\
    　}\ \
    　actions{ -- -- -- --　アクション処理\
    　　set\_D;\
    　}\ 
    　size : 32; -- -- --　テーブルサイズ(エントリ数)\  
  }
  ])
  line("switch.east","l2.west")

  rect((0,-3.5), (rel: (8,3)),name: "parse")
  content((rel:(0,-0.5),to:"parse.south"),[parse.p4])
  content((rel:(0,0),to:"parse"),
  [
    ヘッダ解析\
    parser parse_ethernet{\
    　extract(ethernet.ethertype);\     
    }
  ])
  line("switch.east","parse.west")
 
  
})

== あれこれ
=== アクション命令(action)
- modify_field(A.a,number)
A.a(ヘッダ)にnumber(値)を格納する。
- add_to_field(ipv4.ttl,-1)
ttl(time to live)カウントを１減らす
=== ヘッダ型(header_typ)
- ingress_metadata_t
- egress_metadata_t
- intrinsic_metadata_t
- global_config_metadata_t

=== テーブル構文(table)
- 