FROM alpine:latest

LABEL maintainer="Simon Emms <simon@simonemms.com>"

ARG ATOMIC_PARSLEY_URL="https://bitbucket.org/shield007/atomicparsley/raw/68337c0c05ec4ba2ad47012303121aaede25e6df/downloads/build_linux_x86_64/AtomicParsley"
ARG GET_IPLAYER_URL="https://raw.github.com/get-iplayer/get_iplayer/master/get_iplayer"

ENV OUTPUT_DIR=/opt/data

WORKDIR /opt/get_iplayer
ADD run.sh .

VOLUME ${OUTPUT_DIR}

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
  && rm ./get_iplayer \
  && chmod 755 ./run.sh

ENTRYPOINT [ "./run.sh" ]
