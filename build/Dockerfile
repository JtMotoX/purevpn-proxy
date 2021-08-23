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
	rm -f purevpn_amd64.deb

# Determine the username and uid to run container
ENV CONTAINER_USER=purevpn
ENV CONTAINER_USERID=1000

# Create user to run container
RUN useradd -m -u $CONTAINER_USERID -p password $CONTAINER_USER

# Disable IPV6
RUN echo "net.ipv6.conf.all.disable_ipv6=1" >>/etc/sysctl.conf && \
	echo "net.ipv6.conf.default.disable_ipv6=1" >>/etc/sysctl.conf

# Install dante proxy server
RUN apt-get update && \
	apt-get install -y dante-server && \
	rm -rf /var/lib/apt/lists/* && \
	touch /var/log/sockd.log && \
	chown $CONTAINER_USER:$CONTAINER_USER /var/log/sockd.log

# Allow user to perform tasks as sudo
RUN echo "$CONTAINER_USER ALL=NOPASSWD:SETENV: /scripts/*.sh" >>/etc/sudoers

# Add dante configs
COPY ./configs/danted.conf /etc/danted.conf
RUN chmod 777 /etc/danted.conf
RUN ls -l /etc/danted.conf

# Copy scripts to image
COPY ./scripts /scripts
RUN chown -R root:root /scripts && \
	chmod -R 755 /scripts

# this is required to perform the purevpn login
RUN echo 'export USER="$(whoami)"' >>/etc/profile

USER $CONTAINER_USER
WORKDIR /home/$CONTAINER_USER
RUN echo ". /etc/profile" >>~/.bashrc

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["/bin/bash"]