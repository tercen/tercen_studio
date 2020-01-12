FROM rocker/tidyverse:3.5.3

RUN apt-get install -y curl && curl --version

ENV PATH="/home/rstudio/.cargo/bin:${PATH}"
RUN echo "PATH=/home/rstudio/.cargo/bin:${PATH}" >> /usr/local/lib/R/etc/Renviron

USER rstudio
WORKDIR /home/rstudio
# Global site-wide config -- neeeded for building packages
RUN mkdir -p /home/rstudio/.R/ \
    && echo "MAKE=make -j8\n" >> /home/rstudio/.R/Makevars

RUN echo "rust version 1.39.0 (4560ea788 2019-11-04)"

RUN curl -v https://sh.rustup.rs --output rustup-init && chmod +x rustup-init && ./rustup-init -y -q

USER root

RUN apt-get remove -y curl && \
    wget https://curl.haxx.se/download/curl-7.58.0.tar.gz && \
    tar -xvf curl-7.58.0.tar.gz && \
    cd curl-7.58.0 && \
    ./configure && \
    make && \
    make install && \
    make clean && \
    cd .. && \
    rm -r curl-7.58.0 && \
    rm curl-7.58.0.tar.gz


RUN echo 'options("tercen.serviceUri"="http://tercen:5400/api/v1/")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options("tercen.username"="admin")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options("tercen.password"="admin")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options(renv.consent = TRUE)' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options(repos=c(TERCEN="https://cran.tercen.com/api/v1/rlib/tercen",\
     CRAN="https://cran.tercen.com/api/v1/rlib/CRAN", \
     BioCsoft="https://cran.tercen.com/api/v1/rlib/BioCsoft-3.8", \
     BioCann="https://cran.tercen.com/api/v1/rlib/BioCann-3.8", \
     BioCexp="https://cran.tercen.com/api/v1/rlib/BioCexp-3.8", \
     BioCworkflows="https://cran.tercen.com/api/v1/rlib/BioCworkflows-3.8" \
     ))' >> /usr/local/lib/R/etc/Rprofile.site


# install renv
# see https://github.com/tercen/log_operator/blob/master/renv/activate.R
ENV RENV_PATHS_LIBRARY="/usr/local/lib/R/renv/library"
RUN mkdir -p ${RENV_PATHS_LIBRARY}/R-3.5/x86_64-pc-linux-gnu
RUN R -e "remotes::install_github('rstudio/renv@0.9.2-19', lib='${RENV_PATHS_LIBRARY}/R-3.5/x86_64-pc-linux-gnu')"

USER rstudio
RUN R -e "remotes::install_github('rstudio/renv@0.9.2-19')"
RUN R -e "install.packages(c('Rtsne', 'randomForest', 'ranger', 'rbenchmark', 'lme4' , 'shinyjs'))"
RUN R -e "remotes::install_github('JinmiaoChenLab/ClusterX')"

RUN R -e "install.packages('tercen')"

RUN mkdir -p /home/rstudio/.local/share/renv

USER root

VOLUME /home/rstudio/.local/share/renv