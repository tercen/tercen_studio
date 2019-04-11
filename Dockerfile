FROM rocker/tidyverse:3.5.3

RUN apt-get remove -y curl && \
    wget https://curl.haxx.se/download/curl-7.58.0.tar.gz && \
    tar -xvf curl-7.58.0.tar.gz && \
    cd curl-7.58.0 && \
    ./configure && \
    make && \
    make install

RUN apt-get update && apt-get install -y cargo rustc

RUN R -e "install.packages('packrat')"

RUN R -e "devtools::install_github('tercen/TSON', ref = '1.4.4-rtson', subdir='rtson', upgrade_dependencies = FALSE, args='--no-multiarch')" \
    R -e "devtools::install_github('tercen/teRcen', ref = '0.7.1', upgrade_dependencies = FALSE, args='--no-multiarch')"

COPY tercen_examples/ /home/rstudio/tercen_examples/
RUN  chown -R rstudio:rstudio /home/rstudio/tercen_examples/

