FROM ubuntu
RUN apt-get update &&\
    apt-get -y install --no-install-recommends apcupsd &&\
    rm -rif /var/lib/apt/lists/*
COPY apcupsd /etc/default/apcupsd
COPY apcupsd.conf /etc/apcupsd/apcupsd.conf
COPY hosts.conf /etc/apcupsd/hosts.conf
CMD ["/sbin/apcupsd", "-b"]
