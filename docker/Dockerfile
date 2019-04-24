FROM rocker/tidyverse:3.5.3

RUN apt-get install -y curl && curl --version

ENV PATH="/home/rstudio/.cargo/bin:${PATH}"
RUN echo "PATH=/home/rstudio/.cargo/bin:${PATH}" >> /usr/local/lib/R/etc/Renviron

USER rstudio
WORKDIR /home/rstudio

RUN curl -v https://sh.rustup.rs --output rustup-init && chmod +x rustup-init && ./rustup-init -y

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


USER rstudio

RUN R -e "install.packages('packrat')"

RUN R -e "devtools::install_github('tercen/teRcen', ref = '0.8.8', upgrade_dependencies = TRUE, args='--no-multiarch')"

USER root
