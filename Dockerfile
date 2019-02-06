#use latest armv7hf compatible OS
FROM balenalib/armv7hf-debian:stretch

#dynamic build arguments coming from the /hook/build file
ARG BUILD_DATE
ARG VCS_REF

#metadata labels
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/HilscherAutomation/netPI-teamviewer" \
      org.label-schema.vcs-ref=$VCS_REF

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry)
RUN [ "cross-build-start" ]

#version
ENV HILSCHERNETPI_TEAMVIEWER 1.0.0

#labeling
LABEL maintainer="netpi@hilscher.com" \
      version=$HILSCHERNETPI_TEAMVIEWER \
      description="TeamViewer"

#TeamViewer default parameter
ENV TEAMVIEWER_LICENSE show
ENV TEAMVIEWER_PASSWD 12345678

#install dpkg & fbterm
RUN apt-get update  \
    && apt-get install -y dpkg \
#install TeamViewer
    && curl -fSL -o /tmp/teamviewer-host_armhf.deb https://dl.tvcdn.de/download/linux/version_14x/teamviewer-host_14.1.9025_armhf.deb \
    && dpkg -i /tmp/teamviewer-host_armhf.deb || apt-get install -yq --no-install-recommends -f \
#remove TeamViewer login details created during build process
    && rm /opt/teamviewer/config/* \
    && rm /opt/teamviewer/logfiles/* \
#clean up
    && rm -rf /tmp/* \
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*
 
#set entrypoint
COPY "./init.d/*" /etc/init.d/
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]
