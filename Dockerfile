|@FROM phusion/baseimage:master
LABEL maintainer="ograna"

# INSTALL COMPI
ADD image-files/compi.tar.gz /

# PLACE HERE YOUR DEPENDENCIES (SOFTWARE NEEDED BY YOUR PIPELINE)
RUN apt-get -y update
RUN apt-get -y install wget
RUN apt-get -y install bzip2
RUN apt-get -y install 
RUN wget http://www.drive5.com/uclust/uclustq1.2.22_i86linux64
RUN chmod 755 uclustq1.2.22_i86linux64
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN rm -rf /root/miniconda3
RUN bash Miniconda3-latest-Linux-x86_64.sh -b
ENV PATH=/root/miniconda3/bin:$PATH
RUN conda update -n base -c defaults conda
RUN conda config --add channels defaults
RUN conda config --add channels anaconda
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
RUN conda create -n qiime1 python=2.7 qiime matplotlib=1.4.3 mock nose numpy h5py
RUN mkdir -p /root/.config/matplotlib
RUN echo "backend : Agg" > /root/.config/matplotlib/matplotlibrc

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' && apt-get update && apt-get -y install r-base
RUN apt-get -y install libssl-dev
RUN apt-get -y install libcurl4-openssl-dev libxml2-dev
RUN wget https://cran.r-project.org/src/contrib/Archive/Rcpp/Rcpp_1.0.1.tar.gz
RUN wget https://cran.r-project.org/src/contrib/Archive/RJSONIO/RJSONIO_1.3-1.1.tar.gz
RUN wget https://cran.r-project.org/src/contrib/Archive/biom/biom_0.3.12.tar.gz
RUN wget https://cran.r-project.org/src/contrib/Archive/RcppArmadillo/RcppArmadillo_0.8.100.1.0.tar.gz
RUN wget https://cran.r-project.org/src/contrib/plyr_1.8.4.tar.gz
RUN /usr/bin/R CMD INSTALL Rcpp_1.0.1.tar.gz
RUN /usr/bin/R CMD INSTALL RcppArmadillo_0.8.100.1.0.tar.gz
RUN /usr/bin/R CMD INSTALL RJSONIO_1.3-1.1.tar.gz
RUN /usr/bin/R CMD INSTALL plyr_1.8.4.tar.gz
RUN /usr/bin/R CMD INSTALL biom_0.3.12.tar.gz
RUN /usr/bin/R -e "install.packages('methods',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN /usr/bin/R -e "install.packages('jsonlite',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN /usr/bin/R -e "install.packages('tseries',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN /usr/bin/R -e "install.packages('yhatr')"
RUN /usr/bin/R -e "install.packages('ggplot2')"
RUN /usr/bin/R -e "install.packages('plyr')"
RUN /usr/bin/R -e "install.packages('reshape2')"
RUN /usr/bin/R -e "install.packages('forecast')"
RUN /usr/bin/R -e "install.packages('stringr')"
RUN /usr/bin/R -e "install.packages('lubridate')"
RUN /usr/bin/R -e "install.packages('randomForest')"
RUN /usr/bin/R -e "install.packages('rpart')"
RUN /usr/bin/R -e "install.packages('e1071')"
RUN /usr/bin/R -e "install.packages('kknn')"
RUN /usr/bin/R -e "install.packages('XML')"
RUN /usr/bin/R -e "if(!requireNamespace('BiocManager', quietly = TRUE)){install.packages('BiocManager')}; \
BiocManager::install('phyloseq'); \
BiocManager::install('metagenomeSeq'); \
BiocManager::install('vegan'); \
BiocManager::install('randomforests'); \
BiocManager::install('ape'); \
BiocManager::install('microbiome'); \
BiocManager::install('dplyr'); \
BiocManager::install('pheatmap'); \
BiocManager::install('RColorBrewer'); \
BiocManager::install('ggtree'); \
BiocManager::install('DESeq2'); \ 
BiocManager::install('edgeR'); \
if(!require('DT')){install.packages('DT')}; \
BiocManager::install('openxlsx')"


WORKDIR "/"
RUN wget http://www.clustal.org/download/current/clustalw-2.1-linux-x86_64-libcppstatic.tar.gz && tar -xvf clustalw-2.1-linux-x86_64-libcppstatic.tar.gz
WORKDIR "/clustalw-2.1-linux-x86_64-libcppstatic"
RUN ln -s clustalw2 clustalw
WORKDIR "/"
RUN wget https://github.com/ibest/clearcut/archive/master.zip && unzip master.zip
WORKDIR "clearcut-master"
RUN make
WORKDIR "/"
RUN wget https://github.com/jstjohn/SeqPrep/archive/master.zip -O SeqPrep-master.zip && unzip SeqPrep-master.zip
WORKDIR "/SeqPrep-master"
RUN make

WORKDIR "/"
RUN wget https://github.com/curl/curl/releases/download/curl-7_55_0/curl-7.55.0.tar.gz && tar -xvf curl-7.55.0.tar.gz
WORKDIR "/curl-7.55.0"
RUN ./configure && make && make install

WORKDIR "/"
RUN /usr/bin/R -e "install.packages('devtools', dependencies = TRUE,repos='http://cran.rstudio.com/')"
RUN ln -s /bin/tar /bin/gtar
RUN apt-get -y install libssh2-1-dev

RUN wget https://www.niehs.nih.gov/research/resources/assets/docs/ancom_version_112.zip && unzip ancom_version_112.zip
RUN wget https://cran.r-project.org/src/contrib/doParallel_1.0.15.tar.gz
RUN /usr/bin/R -e "install.packages('coin')"
RUN /usr/bin/R -e "install.packages('exactRankTests')"
RUN /usr/bin/R CMD INSTALL doParallel_1.0.15.tar.gz
RUN /usr/bin/R -e "install.packages('ancom.R_1.1-2.tar.gz')"


WORKDIR "/"
RUN /usr/bin/R -e "install.packages('optparse')"

#RUN conda install --yes -n qiime1 -c bioconda bioconductor-rhdf5lib
#RUN conda install --yes -n qiime1 jags r-rjags
RUN /usr/bin/R -e "devtools::install_github(repo = 'UVic-omics/selbal')"
RUN apt-get -y install gettext-base
RUN conda install --yes -n qiime1 blast-legacy=2.2.22


RUN /usr/bin/R -e "install.packages('pheatmap')"

# ADD PIPELINE
ADD pipeline.xml pipeline.xml
ENTRYPOINT ["/compi", "run",  "-p", "/pipeline.xml"]
