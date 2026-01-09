#pagebreak()
= White Box Switch
== White Box Switchとは
@onie
通常のスイッチと違い、H/WとS/Wが分離しており、ユーザが自由にカスタマイズできるスイッチである。CNFと比べてASICといったハードウェア資源があることにより、高性能なネットワーク処理を可能にするが、迅速な機能変更は不可能である。

== ASICとは
ASIC(Application Specific Integrated Circuit)とは、ユーザの用途に合わせて、必要な機能を組み合わせて設計できる半導体集積回路である。

== BMCとMain CPUの違い
以下の図のようにWBSにはBMC CPUとMain CPUがあり、前者は電源やファンなどのHW管理を、後者はテーブル・ルールの設定等のSW管理を行う。さらにBMCはCPUを管理し、CPUはASICを制御する。そのためASICを動かすためには,Main CPUにより制御するが、その際にBMCからのボード情報が必要になる。
#figure(caption: [WBSの構成])[
  #image("/image/WBS_image.png", width: 70%)
]