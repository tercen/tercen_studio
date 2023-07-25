FROM lscr.io/linuxserver/code-server:4.14.1

USER root 

RUN apt-get update && apt-get install -y build-essential \
	git \
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
	tk-dev \
	python3-openssl \
	python3-pip \
 	python3-venv

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
RUN ~/.pyenv/bin/pyenv install 3.9.0

RUN pip3 install wheel
