## 5.2 模式和非模式物种的富集分析
### 1. GO富集分析
#### 1.1 模式物种的GO富集分析
&emsp; 大部分模式物种在Bioconductor库可以查询到对应的orgdb。orgdb数据库本质是一个R包，library(org.Hs.tair.db)加载后才能使用。
```
在https://bioconductor.org/packages/release/BiocViews.html 搜索OrgDb，当前已有19个模式生物orgdb。
1	org.Hs.eg.db	 Human	3
2	org.Mm.eg.db	 Mouse	5
3	org.Rn.eg.db	 Rat	15
4	org.Dm.eg.db	 Fly	23
5	org.At.tair.db	 Arabidopsis	32
6	org.Dr.eg.db	 Zebrafish	33
7	org.Sc.sgd.db	 Yeast	39
8	org.Ce.eg.db	 Worm	45
9	org.Bt.eg.db	 Bovine	48
10	org.Gg.eg.db	 Chicken	49
11	org.Ss.eg.db	 Pig	55
12	org.Mmu.eg.db	 Rhesus	56
13	org.Cf.eg.db	 Canine	61
14	org.EcK12.eg.db	 E coli strain K12	70
15	org.Xl.eg.db	 Xenopus	74
16	org.Pt.eg.db	 Chimp	88
17	org.Ag.eg.db	 Anopheles	90
18	org.EcSakai.eg.db	 E coli strain Sakai	109
19	org.Mxanthus.db	 Myxococcus xanthus DK 1622	272
```
#### 1.2 非模式物种的GO富集分析
###### 1.2.1 AnnotationHub上查询可用orgdb
&emsp; 对于不能在Bioconductor库查询到orgdb的物种，优先在AnnotationHub上查询是否有在线注释可以创建OrgDb对象，例如：
```
镜像：172.16.50.43/lt/enrich:1.1
library(AnnotationHub)
hub <- AnnotationHub()
query(hub, "Oryza_sativa")
Oryza_sativa <- hub[['AH101068']]
#AnnotationHub with 5 records
# snapshotDate(): 2022-04-25
# $dataprovider: ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/, WikiPathways, Inpara...
# $species: Oryza sativa, Oryza sativa_subsp._japonica, Oryza sativa_Japonic...
# $rdataclass: OrgDb, Tibble, Inparanoid8Db
# additional mcols(): taxonomyid, genome, description,
# coordinate_1_based, maintainer, rdatadateadded, preparerclass, tags,
# rdatapath, sourceurl, sourcetype 
# retrieve records with, e.g., 'object[["AH10561"]]'                                          
  AH10561  | hom.Oryza_sativa.inp8.sqlite                        
  AH91809  | wikipathways_Oryza_sativa_metabolites.rda           
  AH101066 | org.Oryza_sativa_(japonica_cultivar-group).eg.sqlite
  AH101067 | org.Oryza_sativa_Japonica_Group.eg.sqlite           
  AH101068 | org.Oryza_sativa_subsp._japonica.eg.sqlite 

library(AnnotationDbi)
saveDb(Oryza_sativa,file="Oryza_sativa.sqlite") 	#把Cgriseus对象保存成Cgriseus.sqlite文件
Oryza_sativa<-loadDb(file="Oryza_sativa.sqlite") 	#载入Cgriseus.sqlite文件，保存到Cgriseus

> columns(sqlite)
[1] "ACCNUM" "ALIAS" "ENSEMBL" "ENSEMBLPROT"
[5] "ENSEMBLTRANS" "ENTREZID" "ENZYME" "EVIDENCE"
[9] "EVIDENCEALL" "GENENAME" "GENETYPE" "GO"
[13] "GOALL" "IPI" "MAP" "OMIM"
[17] "ONTOLOGY" "ONTOLOGYALL" "PATH" "PFAM"
[21] "PMID" "PROSITE" "REFSEQ" "SYMBOL"
[25] "UCSCKG" "UNIPROT"
```
###### 1.2.2 eggnog-mapper比对自构建orgdb
&emsp; 如果也查询不到可以orgdb，则可选择利用eggnog-mapper来进行近缘比对，直接用enricher进行富集分析，例如：
```
###在线比对：
在线工具：http://eggnog-mapper.embl.de/ 
1.选择本地输入文件，蛋白序列或者cds序列，一般可以NCBI直接下载；
2.给定一个邮箱地址；
3.点击 Start；
4.等待文件上传，等待弹出页面，检查邮箱，点击Click to manage your job；
5.等待新窗口中任务完成，检查邮箱，点击Access your job files here；

###离线比对
软件下载：github：https://github.com/eggnogdb/eggnog-mapper 
软件安装：pip install eggnog-mapper  
下载EggNOG数据库：http://eggnog5.embl.de/download/ 
重点是（emapperdb-5.0,2中的eggnog.db.gz，eggnog_proteins.dmnd.gz 这两个文件，放到/soft/eggnog-mapper/data/ 目录中）
运行命令：emapper.py -i mm39.pep.fa -o mm39 -d euk --cpu 10 -dbmem
-i	 	蛋白组序列文件
-o	 	输出前缀，自动补充.emapper.annotations
-dbmem	把全部数据库存入内存，提高运行效率
--tax_scope: （物种选择，可查看eggnogmapper/annotation/tax_scopes）Chordata（脊椎动物），Viridiplantae（绿色植物）等。

###结果解释：
mm39.emapper.hmm_hits
mm39.emapper.seed_orthologs
mm39.emapper.annotations：最终的注释结果
提取*.emapper.annotations转化成.anno文件，即可用于做enricher注释。
```

### 2. KEGG富集分析
#### 2.1 模式物种的KEGGG富集分析
&emsp; 首先在KEGG数据库查询是否已有基因组物种，例如：
```
###在线搜索：
https://www.genome.jp/kegg/catalog/org_list.html  
(Eukaryotes: 962    Bacteria: 8044    Archaea: 418)
例如：水稻就是 osa，没有籼稻（Oryza sativa subsp. indica）
osa	KGB	 Oryza sativa japonica (Japanese rice) 	RefSeq
dosa    Oryza sativa japonica (Japanese rice) (RAPDB)	RAP-DB

###离线搜索：
library(clusterProfiler)
search_kegg_organism('Eucalyptus', by='scientific_name')
kegg_code   scientific_name 		common_name
egr 		Eucalyptus grandis      rose
```
#### 2.2 非模式物种的kegg富集分析
&emsp; 如果没有，参考"1.2 非模式物种的GO富集分析" 块内容。

### 3. 脚本管理与处理示例
#### 3.1 代码管理
&emsp; 所有相关代码都已整理保存到git中：  git@10.0.1.111:lzw/genecloud_enrichment.git
```
$ tree genecloud_enrichment
genecloud_enrichment
├── 1.0_go
│   └── animal.deg_enrich.v3.3.r
├── 2.0_kegg
│   └── animal.deg_enrich.v3.3.r
├── 3.0_gsea
│   └── symbolTpm2gsea_gsea.wdl
├── 4.0_sqlite2anno
│   ├── func_kegg_info.py
│   ├── kegg_list_organism.txt
│   ├── org.rno.eg.db.sqlite
│   ├── pathway_db
│   │   ├── rno.json
│   │   ├── rno_kegg_info.tsv
│   │   ├── rno_link.txt
│   │   ├── rno_list.txt
│   │   └── rno_pathway_info.tsv
│   ├── rno.gene_symbol.list
│   ├── rno.go.anno
│   ├── rno.kegg.anno
│   ├── sqlite2anno.rno.R
│   ├── step1_getPathDb.sh
│   ├── step2_sqlite2anno.R
│   └── work.sh
├── 5.0_emapperAnnotations2anno
│   ├── build_anno.py
│   ├── mm19_dir
│   │   ├── mm19.go.anno
│   │   └── mm19.kegg.anno
│   ├── out.emapper.annotations
│   └── work.sh
├── 6.0_goKeggTerm2gmt
│   ├── creat_gsea_gmt.R
│   ├── GO.rno.symbols.gmt
│   ├── KEGG.rno.symbols.gmt
│   └── work.sh
├── 7.0_rnaPlatformAnnoTable
│   ├── get_rnaPlatForm_annotation_table.R
│   ├── rno_annotable.tsv
│   └── work.sh
├── 8.0_knownTermDatabase
│   ├── go.term.csv
│   ├── kegg_info_extract.py
│   ├── kegg_list_organism.txt
│   ├── kegg.term.csv
│   ├── pathway.html
│   └── work.sh
├── git_submit.sh
└── README.md
```
#### 3.2 目录说明
&emsp; git中总共包含8个目录，说明如下：    

|  目录  | 说明  |
|  ----  | ----  |
| 1.0_go   | 存放GO注释示例脚本 |
| 2.0_kegg | 存放KEGG注释示例脚本 |
| 3.0_gsea | 存放GSEA富集分析示例脚本 |
| 4.0_sqlite2anno | 对于已有orgdb的物种，可将.sqlite文件转成.anno文件 |
| 5.0_emapperAnnotations2anno | 对于无orgdb物种，将emapper比对后的.annotation文件转成.anno文件 |
| 6.0_goKeggTerm2gmt | 基于.sqlite或.anno提取通路基因集，用于做GSEA分析默认基因集输入 |
| 7.0_rnaPlatformAnnoTable | 基于.anno或.sqlite提取最全的gene与通路表，提交RNA平台做gene注释 |
| 8.0_knownTermDatabase | GO2TERM和PATHWAY2TERM最全对应表下载与整理 |


#### 3.3 示例说明
&emsp; 各处理目录下都存放了相关运行示例，其中补充了模块目的，处理环境，脚本运行示例，都已测试过，可正常运行。 
 
&emsp; 4.0_sqlite2anno/work.sh  

&emsp; 5.0_emapperAnnotations2anno/work.sh  

&emsp; 6.0_goKeggTerm2gmt/work.sh  

&emsp; 7.0_rnaPlatformAnnoTable/work.sh  

&emsp; 8.0_knownTermDatabase/work.sh  

```
##示例
cat 7.0_rnaPlatformAnnoTable/work.sh

######基于anno 或者sqlite注释文件 提取最全的gene与通路注释表，用于提交RNA平台做gene注释
######深圳terminal: podman run -it -v /GeneCloud001/genecloud/DB/pubDB/ide/R:/opt/R/:ro  172.16.50.43/apseq/rstudio:latest /bin/bash

species="rno"
sqlite="../4.0_sqlite2anno/org.rno.eg.db.sqlite"
genesymbol="../4.0_sqlite2anno/rno.gene_symbol.list"
keggdb="../4.0_sqlite2anno/pathway_db/rno_kegg_info.tsv"

Rscript get_rnaPlatForm_annotation_table.R \
--species $species \
--genesymbol $genesymbol \
--orgdb $sqlite \
--keggdb $keggdb 
```

### 4. 其它补充知识
#### 4.1 GO term信息查询
&emsp; 在GO官网使用的AmiGO2网站可查询GO ID和GO term信息，查询地址：https://amigo.geneontology.org/amigo/landing  
#### 4.2 kegg pathway信息查询
&emsp; 在KEGG Pathway中可查询，查询地址：https://www.kegg.jp/kegg/pathway.html 
#### 4.3 GO2TERM最全对应关系表下载
&emsp; http://current.geneontology.org/ontology/go.obo 
#### 4.4 kegg 已知物种下载
&emsp; wget https://rest.kegg.jp/list/organism -O kegg_list_organism.txt
#### 4.5 PATHWAY2TERM 最全对应关系表下载
&emsp; wget https://www.genome.jp/kegg/pathway.html
###### 4.6 GO富集分析命令enrichGO简介
```
enrichGO(
  gene,
  OrgDb,
  keyType = "ENTREZID",
  ont = "MF",
  pvalueCutoff = 0.05,
  pAdjustMethod = "BH",
  universe,
  qvalueCutoff = 0.2,
  minGSSize = 10,
  maxGSSize = 500,
  readable = FALSE,
  pool = FALSE
)
```

| 参数  | 说明  |
| ----  | ----  |
| gene  | a vector of entrez gene id. |
| OrgDb | OrgDb |
|keyType |keytype of input gene |
|ont |One of "BP", "MF", and "CC" subontologies, or "ALL" for all three.|
|pvalueCutoff |adjusted pvalue cutoff on enrichment tests to report|
|pAdjustMethod|one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr","none"|
|universe|background genes. If missing, the all genes listed in the database (eg TERM2GENE table) will be used as background.|
|qvalueCutoff|qvalue cutoff on enrichment tests to report as significant. Tests mustpass i) pvalueCutoff on unadjusted pvalues, ii) pvalueCutoff on adjusted pvalues and iii) qvalueCutoff on qvalues to be reported.|
|minGSSize |minimal size of genes annotated by Ontology term for testing.|
|maxGSSize |maximal size of genes annotated for testing |
|readable |whether mapping gene ID to gene Name|
|pool |If ont='ALL', whether pool 3 GO sub-ontologies|

###### 4.7 KEGG富集分析命令enrichKEGG简介
```
enrichKEGG(
  gene,
  organism = "hsa",
  keyType = "kegg",
  pvalueCutoff = 0.05,
  pAdjustMethod = "BH",
  universe,
  minGSSize = 10,
  maxGSSize = 500,
  qvalueCutoff = 0.2,
  use_internal_data = FALSE
)
```

|  参数  | 说明  |
|  ----  | ----  |
| gene  | a vector of entrez gene id. |
| organism | supported organism listed in 'https://www.genome.jp/kegg/catalog/org_list.html'|
| keyType| one of "kegg", 'ncbi-geneid', 'ncib-proteinid' and 'uniprot'|
|pvalueCutoff | adjusted pvalue cutoff on enrichment tests to report  |
|pAdjustMethod  | one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY","fdr", "none"  |
|universe  | background genes. If missing, the all genes listed in the database (eg TERM2GENE table) will be used as background.  |
|minGSSize  | minimal size of genes annotated by Ontology term for testing. |
|maxGSSize  | maximal size of genes annotated for testing  |
|qvalueCutoff  | qvalue cutoff on enrichment tests to report as significant. Tests must pass i) pvalueCutoff on unadjusted pvalues, ii) pvalueCutoff on adjusted pvalues and iii) qvalueCutoff on qvalues to be reported.  |
|use_internal_data| logical, use KEGG.db or latest online KEGG data |

###### 4.8 富集分析命令enricher简介
```
enricher(
  gene,
  pvalueCutoff = 0.05,
  pAdjustMethod = "BH",
  universe = NULL,
  minGSSize = 10,
  maxGSSize = 500,
  qvalueCutoff = 0.2,
  gson = NULL,
  TERM2GENE,
  TERM2NAME = NA
)
```

|  参数  | 说明  |
|  ----  | ----  |
|gene  | a vector of gene id. |
|pvalueCutoff|adjusted pvalue cutoff on enrichment tests to report  |
|pAdjustMethod|one of "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr","none"|
|universe|background genes. If missing, the all genes listed in the database (eg TERM2GENE table) will be used as background.|
|minGSSize  |minimal size of genes annotated for testing  |
|maxGSSize  |maximal size of genes annotated for testing  |
|qvalueCutoff |qvalue cutoff on enrichment tests to report as significant. Tests must pass i) pvalueCutoff on unadjusted pvalues, ii) pvalueCutoff on adjusted pvalues and iii) qvalueCutoff on qvalues to be reported.  |
|gson  |a GSON object, if not NULL, use it as annotation data  |
|TERM2GENE|user input annotation of TERM TO GENE mapping, a data.frame of 2 column with term and gene. Only used when gson is NULL.  |
|TERM2NAME |user input of TERM TO NAME mapping, a data.frame of 2 column with term and name. Only used when gson is NULL.  |

参考文档1：https://zhuanlan.zhihu.com/p/536082841     

参考文档2：https://www.jianshu.com/p/f2e4dbaae719   




