FROM ubuntu

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        curl ca-certificates \
        jq \
        libcurl3-gnutls \
        libldap-2.4-2 \
        netcat-openbsd \
        pciutils \
        sudo \
        wget \
        gdebi-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl --output zabbix-release.deb https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2+bionic_all.deb
RUN dpkg -i zabbix-release.deb

RUN apt-get update &&\
    apt-get -y install --no-install-recommends apcupsd &&\
    apt-get -y install zabbix-agent &&\
    rm -rif /var/lib/apt/lists/*

COPY apcupsd /etc/default/apcupsd
COPY apcupsd.conf /etc/apcupsd/apcupsd.conf
COPY hosts.conf /etc/apcupsd/hosts.conf

COPY sudoers.d/zabbix /etc/sudoers.d/zabbix
RUN chmod 400 /etc/sudoers.d/zabbix
COPY userparameter_apcupsd.conf /etc/zabbix/zabbix_agentd.d/userparameter_apcupsd.conf

COPY run.sh /

EXPOSE 10050

CMD ["/bin/bash", "/run.sh"]
