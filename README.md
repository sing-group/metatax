 # Metatax: Metataxonomics with a Compi-based pipeline for Precision Medicine.

Osvaldo Graña-Castro, Hugo López-Fernández, Alba Nogueira-Rodríguez, Florentino Fdez-Riverola, Fátima Al-Sharour and Daniel Glez-Peña.

A Docker image is available for this pipeline in [this Docker Hub repository](https://hub.docker.com/r/singgroup/metatax).






# Running the pipeline with sample data

It is possible to test the pipeline using our sample data available [here](). Download the ZIP file and decompress it in your local file system. Then, run the following command, changing the `/path/to/metataxonomics/data/` to the path where you have the decompressed data.


(i) Download sequencing data from SRA: 

Read files can be downloaded from SRA (ID SRP116709) with the following command line (provided that Docker-CE is already installed):

*** Download first the required files SRR_Acc_List.txt, SraRunTable.txt, parameters.txt, map.tsv and uc_fast_params.txt from the following link: http://static.sing-group.org/software/compi/pipelines/metatax/supplementary-data-2019.08.08.zip

```
mkdir -p ./FASTQ 
for SRR in $(cat SRR_Acc_List.txt) ; do echo $SRR; docker run -v ./FASTQ:/FASTQ --rm pegi3s/sratoolkit fastq-dump --origfmt --split-files --A $SRR -O ./FASTQ/ ; done
```

(ii) Data preprocessing:

As all the sequenced data in this dataset has been downloaded in step (i), we now select the samples we are working with (16S rRNA human sequences):
```
head -n 1 SraRunTable.txt > 16SrRNA_human.txt ; grep '^AMPLICON' SraRunTable.txt | grep 'Homo sapiens' >> 16SrRNA_human.txt
```

Then we collect the corresponding SRR* and patient codes for the selected samples to a separated file:
```
cut --output-delimiter=',' -f 15,20 16SrRNA_human.txt | grep -v 'Run' > listOfSelectedSamples.txt
```

In order to rename the samples in a clearer way, we rename them using the associated patient codes:
```
mkdir -p ./selectedFASTQ
for file in $(cat listOfSelectedSamples.txt); do echo $file; input=${file/,*/}; output=${file/*,/}; echo $input; echo $output; input1='./FASTQ/'${input}'_1.fastq'; input2='./FASTQ/'${input}'_2.fastq'; output1='./selectedFASTQ/'${output}'_1.fastq'; output2='./selectedFASTQ/'${output}'_2.fastq'; cp $input1 $output1; cp $input2 $output2; done
```

(iii) Executing metatax:

Copy parameters.txt, map.tsv and uc_fast_params.txt files to ./selectedFASTQ directory


Define a metatax execution variable:
```
metatax="docker run --rm -e DISPLAY="$(docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}'):0" -v ./selectedFASTQ:/data -v /tmp/COMPI_logs:/tmp -i compi/metatax"

```

Complete execution (all tasks):
```
$metatax --logs /tmp/ -pa /data/parameters.txt
```

Alternatively, single tasks can be excuted individually or even repeated as follows:
```
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task initialization
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task validate_mapping
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task join_pe
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task multiple_splitLibFastq
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task pick_otus
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task otu_table_summary
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task otu_table_single_rarefaction
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task otu_table_alpha_rarefaction
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task core_diversity
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task alpha_divers
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task beta_divers_through_plots
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task compare_alpha_divers
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task compare_categories
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task filter_otus
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task group_sig
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task align_sequences
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task phylogeny
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task univariate_DESeq2
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task univariate_edgeR
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task ancom
$metatax --logs /tmp/ -pa /data/parameters.txt --single-task selbal
```

