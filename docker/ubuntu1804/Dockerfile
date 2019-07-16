FROM ubuntu:18.04
LABEL maintainer="michael.arnold@clairvoyantsoft.com"

ENV DIST ubuntu1804
ENV PARCEL_DIST bionic
ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_DIR /opt/cloudera/parcels

WORKDIR /BUILD

RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends \
                           pkg-config \
                           perl \
                           ncurses-dev \
                           libssl-dev \
                           libz-dev \
                           m4 \
                           autoconf \
                           python-simplejson \
                           xmlto \
                           libxslt1.1 \
                           libffi-dev \
                           rsync \
                           zip \
                           unzip \
    && rm -rf /var/lib/apt/lists/*

ARG RABBITMQ_VERSION
ENV RABBITMQ_VERSION ${RABBITMQ_VERSION:-3.7.15}
ARG ERLANG_VERSION
ENV ERLANG_VERSION ${ERLANG_VERSION:-22.0}
ARG ELIXIR_VERSION
ENV ELIXIR_VERSION ${ELIXIR_VERSION:-1.8.2}
ARG PARCEL_VERSION
ENV PARCEL_VERSION ${PARCEL_VERSION:-b0}
ENV PARCEL_NAME RABBITMQ-${RABBITMQ_VERSION}-erlang${ERLANG_VERSION}_${PARCEL_VERSION}

COPY otp_src_${ERLANG_VERSION}.tar.gz otp-0001-Do-not-format-man-pages-and-do-not-install-miscellan.patch otp-0002-Remove-rpath.patch otp-0003-Do-not-install-C-sources.patch otp-0007-Do-not-install-erlang-sources.patch /BUILD/
RUN tar xzf /BUILD/otp_src_${ERLANG_VERSION}.tar.gz -C /BUILD

COPY docker/${DIST}/compile_erlang.sh /BUILD
RUN mkdir -p ${INSTALL_DIR}/${PARCEL_NAME} && \
    cd /BUILD/otp_src_${ERLANG_VERSION} && \
    . /BUILD/compile_erlang.sh && \
    ./configure --prefix=${INSTALL_DIR}/${PARCEL_NAME} --enable-shared-zlib --without-javac --without-odbc && \
    export LANG=C \
    make && \
    make install

COPY v${ELIXIR_VERSION}.tar.gz /BUILD/
RUN tar xzf /BUILD/v${ELIXIR_VERSION}.tar.gz -C /BUILD

COPY docker/${DIST}/compile_elixir.sh /BUILD
RUN mkdir -p ${INSTALL_DIR}/${PARCEL_NAME} && \
    cd /BUILD/elixir-${ELIXIR_VERSION} && \
    . /BUILD/compile_elixir.sh && \
    make && \
    make install

#COPY v${RABBITMQ_VERSION}.tar.gz /BUILD/
#RUN tar xzf /BUILD/v${RABBITMQ_VERSION}.tar.gz -C /BUILD
COPY rabbitmq-server-${RABBITMQ_VERSION}.tar.xz /BUILD/
RUN tar xJf /BUILD/rabbitmq-server-${RABBITMQ_VERSION}.tar.xz -C /BUILD

COPY docker/${DIST}/compile_rabbitmq.sh /BUILD
RUN mkdir -p ${INSTALL_DIR}/${PARCEL_NAME} && \
    cd /BUILD/rabbitmq-server-${RABBITMQ_VERSION} && \
    . /BUILD/compile_rabbitmq.sh && \
    make && \
    make install && \
    cd ${INSTALL_DIR}/${PARCEL_NAME}/bin/ && \
    ln -s ../lib/erlang/lib/rabbitmq_server-${RABBITMQ_VERSION}/sbin/* ${INSTALL_DIR}/${PARCEL_NAME}/bin/

RUN . /BUILD/compile_rabbitmq.sh && \
    mkdir -p /etc/rabbitmq && \
    rabbitmq-plugins enable rabbitmq_management && \
    mkdir -p ${INSTALL_DIR}/${PARCEL_NAME}/etc/rabbitmq.dist && \
    cp -p /etc/rabbitmq/* ${INSTALL_DIR}/${PARCEL_NAME}/etc/rabbitmq.dist

COPY meta/ ${INSTALL_DIR}/${PARCEL_NAME}/meta/
RUN sed -e "/\"version\":/s|VERSION|${RABBITMQ_VERSION}-erlang${ERLANG_VERSION}_${PARCEL_VERSION}|" \
        -i ${INSTALL_DIR}/${PARCEL_NAME}/meta/parcel.json

RUN cd ${INSTALL_DIR} && \
    tar zcf /BUILD/${PARCEL_NAME}-${PARCEL_DIST}.parcel ${PARCEL_NAME} && \
    sha1sum /BUILD/${PARCEL_NAME}-${PARCEL_DIST}.parcel | awk '{print $1}' >/BUILD/${PARCEL_NAME}-${PARCEL_DIST}.parcel.sha

CMD /bin/bash

