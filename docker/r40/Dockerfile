FROM rocker/tidyverse:4.0.4

RUN apt-get update && apt-get install -y curl && curl --version

ENV PATH="/home/rstudio/.cargo/bin:${PATH}"
RUN echo "PATH=/home/rstudio/.cargo/bin:${PATH}" >> /usr/local/lib/R/etc/Renviron

USER rstudio
WORKDIR /home/rstudio

RUN mkdir -p /home/rstudio/.R/ \
    && echo "MAKE=make -j8\n" >> /home/rstudio/.R/Makevars

RUN curl -v https://sh.rustup.rs --output rustup-init && chmod +x rustup-init && ./rustup-init -y -q

USER root
# Global site-wide config
RUN echo 'options("tercen.serviceUri"="http://tercen:5400/api/v1/")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options("tercen.username"="admin")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options("tercen.password"="admin")' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options(renv.consent = TRUE)' >> /usr/local/lib/R/etc/Rprofile.site && \
    echo 'options(repos=c(TERCEN="https://cran.tercen.com/api/v1/rlib/tercen",\
     CRAN="https://cran.tercen.com/api/v1/rlib/CRAN", \
     BioCsoft="https://cran.tercen.com/api/v1/rlib/BioCsoft-3.12", \
     BioCann="https://cran.tercen.com/api/v1/rlib/BioCann-3.12", \
     BioCexp="https://cran.tercen.com/api/v1/rlib/BioCexp-3.12", \
     BioCworkflows="https://cran.tercen.com/api/v1/rlib/BioCworkflows-3.12" \
     ))' >> /usr/local/lib/R/etc/Rprofile.site

RUN apt-get install -y python3 python3-dev python3-pip python3-venv

USER rstudio

#RUN python3 -m pip install pandas

RUN mkdir -p /home/rstudio/.local/share/renv

RUN R -e "install.packages(c('renv'))"
RUN echo "install tercen 0.10.8"
RUN R -e "install.packages('tercen')"
RUN R -e "install.packages('reticulate')"
#RETICULATE_MINICONDA_PATH
#RUN R -e "reticulate::install_miniconda()"

USER root

RUN adduser rstudio sudo

VOLUME /home/rstudio/.local/share/renv