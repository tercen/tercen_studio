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
	tar -xf Python-3.9.17.tar.xz && \
	cd Python-3.9.17 && \
	./configure && \
	make && \
	sudo make install && \
	alias python=python3.9

RUN pip3 install wheel

ADD setup-docker.sh /home/abc/setup-docker.sh
RUN chmod +x /home/abc/setup-docker.sh

#USER abc
#
#RUN sudo apt-get update
## install docker cli
#RUN sudo apt-get update -y &&  \
#    sudo apt-get install -y ca-certificates gnupg && \
#    sudo install -m 0755 -d /etc/apt/keyrings && \
#    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
#    sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
#    echo \
#          "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#          "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&\
#    sudo apt-get update -y && \
#    sudo apt-get install -y docker-ce-cli && \
#    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*



#    && \
#    groupadd docker \

#    groupadd docker && \
#    usermod -aG docker abc

