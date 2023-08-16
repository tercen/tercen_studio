FROM lscr.io/linuxserver/code-server:4.14.1

USER root 

RUN apt-get update && apt-get install --no-install-recommends -y build-essential \
	jq \
	libbz2-dev \
	libffi-dev \
	libreadline-dev \
	libssl-dev \
	libsqlite3-dev \
	liblzma-dev \
	zlib1g-dev \
	wget \
	curl \
	llvm \
	libncurses5-dev \
	libncursesw5-dev \
	xz-utils \
	tk-dev

RUN wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tar.xz && \
	cd Python-3.9.17 && \
	./configure && \
	make && \
	sudo make install && \
	alias python=python3.9

RUN pip3 install wheel
