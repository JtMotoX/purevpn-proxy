FROM ubuntu:20.04

# CONFIGURE APT
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils 2>/dev/null && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
	apt-get install -y \
		wget \
		iproute2 \
		net-tools \
		iputils-ping \
		dnsutils \
		expect \
		curl \
		vim \
		sudo \
		&& \
	rm -rf /var/lib/apt/lists/*

# INSTALL FIREWALL FOR KILLSWITCH
RUN apt-get update && \
	apt-get install -y ufw && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i 's/^IPV6=yes$/IPV6=no/' /etc/default/ufw

ENV PUREVPN_VERSION=1.2.5

# Download and install PureVPN
RUN wget -O purevpn_amd64.deb "https://s3.amazonaws.com/purevpn-dialer-assets/linux/app/purevpn_${PUREVPN_VERSION}_amd64.deb" --progress=dot:mega -q && \
	dpkg -i purevpn_amd64.deb && \
	rm -f purevpn_amd64.deb && \
	rm -rf /tmp/_MEI* >/dev/null 2>&1 || true

# Determine the username and uid to run container
ENV CONTAINER_USERNAME=purevpn
ENV CONTAINER_USERID=9001

# Create user to run container
RUN useradd -m -u ${CONTAINER_USERID} -r ${CONTAINER_USERNAME}

# Disable IPV6
RUN echo "net.ipv6.conf.all.disable_ipv6=1" >>/etc/sysctl.conf && \
	echo "net.ipv6.conf.default.disable_ipv6=1" >>/etc/sysctl.conf

# Install dante proxy server
RUN apt-get update && \
	apt-get install -y dante-server && \
	rm -rf /var/lib/apt/lists/* && \
	touch /var/log/sockd.log && \
	chown ${CONTAINER_USERNAME}:${CONTAINER_USERNAME} /var/log/sockd.log

# Install 3proxy proxy server
ENV proxy_dir=/usr/local/3proxy
RUN apt-get update && \
	apt-get install -y \
		git \
		psmisc \
		build-essential \
		&& \
	mkdir -p /tmp/3proxy && \
	cd /tmp/3proxy && \
	git clone https://github.com/z3apa3a/3proxy . && \
	ln -s Makefile.Linux Makefile && \
	make && \
	make install && \
	rm -rf /tmp/3proxy && \
	apt-get remove -y \
		git \
		build-essential \
		&& \
	apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/* && \
	usermod -a -G proxy ${CONTAINER_USERNAME}

# Install headless transmission
ENV TRANSMISSION_LOGFILE=/var/log/transmission.log
RUN apt-get update && \
	apt-get install -y transmission-daemon && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i 's|\(^CONFIG_DIR=.*\)"|\1 --log-debug --logfile '$TRANSMISSION_LOGFILE'"|' /etc/default/transmission-daemon && \
	touch $TRANSMISSION_LOGFILE && \
	chown ${CONTAINER_USERNAME}:${CONTAINER_USERNAME} $TRANSMISSION_LOGFILE && \
	chmod 777 $TRANSMISSION_LOGFILE

# Install envsubst
RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*

# Allow user to perform tasks as sudo
RUN echo "${CONTAINER_USERNAME} ALL=NOPASSWD:SETENV: /scripts/*.sh" >>/etc/sudoers

# Enable IPV4 FORWARDING
RUN echo "net.ipv4.ip_forward=1" >>/etc/sysctl.conf

# Add dante configs
COPY ./configs/danted.conf /etc/danted.conf
RUN chmod 777 /etc/danted.conf
RUN ls -l /etc/danted.conf

# Add 3proxy configs
COPY ./configs/3proxy.cfg ${proxy_dir}/conf/3proxy.cfg
RUN echo ${proxy_dir} && \
	chown --reference ${proxy_dir} ${proxy_dir}/conf/3proxy.cfg && \
	chmod 660 ${proxy_dir}/conf/3proxy.cfg

# Copy transmission settings and allow non-root user to inject variables and apply settings
COPY ./configs/transmission-settings.json /etc/transmission-daemon/settings.template.json

# Copy scripts to image
COPY ./scripts /scripts
RUN chown -R root:root /scripts && \
	chmod -R 755 /scripts

# this is required to perform the purevpn login
RUN echo 'export USER="$(whoami)"' >>/etc/profile

USER ${CONTAINER_USERNAME}
WORKDIR /home/${CONTAINER_USERNAME}
RUN echo ". /etc/profile" >>~/.bashrc

CMD [ "run" ]
ENTRYPOINT [ "/scripts/entrypoint.sh" ]
