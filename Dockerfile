FROM debian:stable-slim
# FROM ubuntu:xenial
# FROM google/debian:jessie

ARG DEBIAN_FRONTEND=noninteractive

RUN /bin/cp -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && apt-get update 1> /dev/null \
 && apt-get upgrade -y -q --no-install-recommends \
 \
 && apt-get -qqy install ca-certificates curl apt-transport-https ttf-wqy-zenhei ttf-unfonts-core \
 \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN curl -q https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >| /etc/apt/sources.list.d/google-chrome.list \
 && apt-get update -qqy  \
 \
 && apt-get -qqy install xvfb google-chrome-unstable \
 \
 && rm /etc/apt/sources.list.d/google-chrome.list \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN mkdir -p /usr/share/man/man1 \
  # && echo "deb https://deb.debian.org/debian jessie-backports main" >> /etc/apt/sources.list.d/jessie-backports.list \
  && echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list.d/jessie-backports.list \
  && apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    -t jessie-backports openjdk-8-jre-headless unzip \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#RUN useradd headless --shell /bin/bash --create-home \
# && usermod -a -G sudo headless \
# && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
# && echo 'headless:nopassword' | chpasswd

RUN mkdir /data


#==========
# Selenium
#==========
RUN  mkdir -p /opt/selenium \
  && curl -q https://selenium-release.storage.googleapis.com/3.3/selenium-server-standalone-3.3.1.jar -o /opt/selenium/selenium-server-standalone.jar


#==================
# Chrome webdriver
#==================
ARG CHROME_DRIVER_VERSION=2.29
RUN curl https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -o /tmp/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver


#========================
# Selenium Configuration
#========================
# As integer, maps to "maxInstances"
ENV NODE_MAX_INSTANCES 1
# As integer, maps to "maxSession"
ENV NODE_MAX_SESSION 1
# In milliseconds, maps to "registerCycle"
ENV NODE_REGISTER_CYCLE 5000
# In milliseconds, maps to "nodePolling"
ENV NODE_POLLING 5000
# In milliseconds, maps to "unregisterIfStillDownAfter"
ENV NODE_UNREGISTER_IF_STILL_DOWN_AFTER 60000
# As integer, maps to "downPollingLimit"
ENV NODE_DOWN_POLLING_LIMIT 2
# As string, maps to "applicationName"
ENV NODE_APPLICATION_NAME ""

COPY generate_config /opt/selenium/generate_config
RUN chmod +x /opt/selenium/generate_config \
 && /opt/selenium/generate_config >| /opt/selenium/config.json


#=================================
# Chrome Launch Script Modication
#=================================
RUN mkdir -p /opt/google/chrome \
 && echo '#!/bin/sh\necho hoge >| /tmp/hoge\nexec google-chrome-unstable --headless --disable-gpu "$@"' >| /opt/google/chrome/google-chrome \
 && chmod +x /opt/google/chrome/google-chrome
# && chown -R headless:headless /opt/selenium

#USER headless
# Following line fixes
# https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 4444
