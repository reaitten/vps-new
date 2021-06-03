FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

#RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse\n' > /etc/apt/sources.list


RUN apt-get upgrade
RUN set -ex; \
    apt-get update \
    && apt-get install -y \
        dbus-x11 \
        nautilus \
        gedit \
        expect \
        sudo \
        bash \
        net-tools \
        novnc \
        xfce4 \
	socat \
	unzip \
        x11vnc \
	xvfb \
        supervisor \
        curl \
        git \
        wget \
        g++ \
	unzip \
        ssh \
	chromium-browser \
	firefox \
        terminator \
        htop \
        gnupg2 \
	locales \
	xfonts-intl-chinese \
	fonts-wqy-microhei \  
	ibus-pinyin \
	ibus \
	ibus-clutter \
	ibus-gtk \
	ibus-gtk3 \
	python3-pip \
	python3-setuptools \
	software-properties-common \
	
    && add-apt-repository ppa:gezakovacs/ppa \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/i/ibus-qt/libibus-qt1_1.3.3-1build2_amd64.deb \
    && sudo apt-get install ./libibus-qt1_1.3.3-1build2_amd64.deb -y \

    && wget http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3.1_amd64.deb \
    && sudo apt-get install ./libicu60_60.2-3ubuntu3.1_amd64.deb -y \

    && wget http://mirrors.kernel.org/ubuntu/pool/universe/i/ibus-qt/ibus-qt4_1.3.3-1build2_amd64.deb \
    && sudo apt-get install ./ibus-qt4_1.3.3-1build2_amd64.deb -y \

    && wget https://github.com/maateen/avro/releases/download/v2.1/avro_2.1-3_all.deb \
    && sudo apt-get install ./avro_2.1-3_all.deb -y \
    && apt-get update \
    && apt-get install ibus-qt4 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*
RUN dpkg-reconfigure locales

RUN wget --no-check-certificate -c https://golang.org/dl/go1.16.3.linux-amd64.tar.gz
RUN tar -C /usr/local -xvzf go1.*.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin


RUN git clone https://github.com/reaitten/bbht.git
RUN chmod +x bbht/install.sh
RUN ./bbht/install.sh
RUN mv bbht/run-after-go.sh /root/tools
RUN chmod +x /root/tools/run-after-go.sh


COPY . /app
RUN chmod +x /app/conf.d/websockify.sh
RUN chmod +x /app/run.sh
RUN chmod +x /app/expect_vnc.sh
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list
RUN echo "deb http://deb.anydesk.com/ all main"  >> /etc/apt/sources.list
RUN wget --no-check-certificate https://dl.google.com/linux/linux_signing_key.pub -P /app
RUN wget --no-check-certificate -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY -O /app/anydesk.key
RUN apt-key add /app/anydesk.key
RUN apt-key add /app/linux_signing_key.pub
RUN set -ex; \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        google-chrome-stable \
	anydesk


ENV UNAME pacat

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes pulseaudio-utils

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p "/home/${UNAME}" && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio

RUN echo xfce4-session >~/.xsession
RUN echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" 

CMD ["/app/run.sh"]
