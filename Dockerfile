FROM node:10-alpine

LABEL maintainer="Simon Emms <simon@simonemms.com>"

ARG ATOMIC_PARSLEY_URL="https://bitbucket.org/shield007/atomicparsley/raw/68337c0c05ec4ba2ad47012303121aaede25e6df/downloads/build_linux_x86_64/AtomicParsley"
ARG GET_IPLAYER_URL="https://raw.github.com/get-iplayer/get_iplayer/master/get_iplayer"
ARG USER_NAME="node"

ENV OUTPUT_DIR=/opt/data

WORKDIR /opt/get_iplayer
ADD index.js .

VOLUME ${OUTPUT_DIR}

## Create the user
#RUN addgroup -g 1000 ${USER_NAME} \
#  && adduser -u 1000 -G ${USER_NAME} -s /bin/sh -D ${USER_NAME}

# Install system dependencies
RUN apk add --no-cache curl

# Get iPlayer dependencies
RUN apk add --no-cache perl-libwww perl-lwp-protocol-https perl-mojolicious perl-xml-libxml \
  && apk add --no-cache ffmpeg \
  && curl -kL -o AtomicParsley ${ATOMIC_PARSLEY_URL} \
  && install -m 755 ./AtomicParsley /usr/local/bin

# Install get_iplayer
RUN curl -kLO ${GET_IPLAYER_URL} \
  && install -m 755 ./get_iplayer /usr/local/bin

# Clean up after ourselves
RUN apk del curl \
  && rm ./AtomicParsley \
  && rm ./get_iplayer

USER ${USER_NAME}

ENTRYPOINT [ "node", "index.js" ]
