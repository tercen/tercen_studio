FROM bioconductor/bioconductor_docker:RELEASE_3_15

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
     CRAN="https://cran.tercen.com/api/v1/rlib/CRAN" \
     ))' >> /usr/local/lib/R/etc/Rprofile.site

RUN apt-get install -y python3 python3-dev python3-pip python3-venv

# needed for flowCut
RUN apt-get install -y libgeos-dev libxt-dev libtiff5-dev libzstd-dev libwebp-dev libglpk-dev

# install docker cli
RUN apt-get update -y &&  \
    apt-get install -y ca-certificates gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
          "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&\
    apt-get update -y && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd docker && \
    usermod -aG docker rstudio

USER rstudio

RUN mkdir -p /home/rstudio/projects
RUN mkdir -p /home/rstudio/.local/share/renv

RUN R -e "install.packages(c('renv'))"
RUN echo "install tercen 0.10.8"
RUN R -e "remotes::install_github('tercen/tim', ref = '0.0.20')"
RUN R -e "remotes::install_github('tercen/teRcen', ref='0.12.7')"
RUN R -e "install.packages('reticulate')"

RUN R -e "BiocManager::install('MetaCyto')"
RUN R -e "BiocManager::install('openCyto')"
RUN R -e "BiocManager::install('diffcyt')"
RUN R -e "BiocManager::install('CATALYST')"

RUN R -e "remotes::install_github('ghar1821/TrackSOM', ref = 'v0.1.0')"
RUN R -e "remotes::install_github('RGLab/scamp', ref='v0.5.0')"
RUN R -e "remotes::install_github('RGLab/FAUST', ref='f900614')"

USER root

RUN adduser rstudio sudo

VOLUME /home/rstudio/projects
VOLUME /home/rstudio/.local/share/renv
