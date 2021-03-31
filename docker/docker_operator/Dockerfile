FROM tensorflow/tensorflow:2.4.1

ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y openssl libssl-dev rustc r-base git

RUN R -e "install.packages('renv')"

WORKDIR /operator

#RUN git clone https://github.com/tercen/mean_operator
#
#WORKDIR /operator/mean_operator
#
#RUN echo 0.12.0 && git pull
#RUN git checkout 0.12.0
#
#RUN R  --vanilla -e "renv::restore(confirm=FALSE)"
#
#ENV TERCEN_SERVICE_URI https://tercen.com
#
#ENTRYPOINT [ "R","--no-save","--no-restore","--no-environ","--slave","-f","main.R", "--args"]
#CMD [ "--taskId", "someid", "--serviceUri", "https://tercen.com", "--token", "sometoken"]

