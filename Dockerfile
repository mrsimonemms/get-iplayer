# Copyright 2025 Simon Emms <simon@simonemms.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM alpine:latest AS atomicparsley
WORKDIR /opt/app
RUN wget https://github.com/wez/atomicparsley/archive/refs/heads/master.zip \
  && unzip master.zip \
  && apk add --no-cache cmake build-base linux-headers zlib-dev
WORKDIR /opt/app/atomicparsley-master
RUN cmake . \
  && cmake --build . --config Release

FROM alpine:latest AS deps
ARG IPLAYER_TO_PLEX_URL="https://github.com/mrsimonemms/iplayer-to-plex/releases/download"
ARG IPLAYER_TO_PLEX_VERSION="0.3.0"
ARG TARGETARCH
WORKDIR /opt/app
RUN if [ "${TARGETARCH}" = "amd64" ]; then echo ${TARGETARCH} > ./arch; elif [ "${TARGETARCH}" = "arm64" ]; then echo ${TARGETARCH} > ./arch; else echo "arm" > ./arch; fi
RUN apk add --no-cache curl jq \
  && curl -L -o get-iplayer.zip $(curl -Ls https://api.github.com/repos/get-iplayer/get_iplayer/releases/latest | jq -r '.zipball_url') \
  && unzip get-iplayer.zip \
  && cp get-iplayer-get_iplayer-*/get_iplayer ./get_iplayer \
  && curl -L -o ./iplayer-to-plex ${IPLAYER_TO_PLEX_URL}/v${IPLAYER_TO_PLEX_VERSION}/iplayer-to-plex-linux-$(cat ./arch)

FROM alpine:latest
ARG USER_NAME="get_iplayer"
ENV OUTPUT_DIR=/opt/data
ENV TMP_OUTPUT_DIR=/opt/tmp
WORKDIR /opt/get_iplayer
COPY --chmod=755 entrypoint.sh .

# Create the user
RUN addgroup -g 1000 ${USER_NAME} \
  && adduser -u 1000 -G ${USER_NAME} -s /bin/sh -D ${USER_NAME}

# Create the temporary output directory
RUN mkdir -p ${TMP_OUTPUT_DIR} \
  && chown ${USER_NAME}:${USER_NAME} ${TMP_OUTPUT_DIR}

# Set the permissions on the output directory
RUN mkdir -p ${OUTPUT_DIR} \
  && chown ${USER_NAME}:${USER_NAME} ${OUTPUT_DIR}
VOLUME ${OUTPUT_DIR}

# Install AtomicParsley
# @link https://github.com/wez/atomicparsley
COPY --from=atomicparsley /opt/app/atomicparsley-master/AtomicParsley /tmp/AtomicParsley
RUN apk add --no-cache libstdc++ \
  && install -m 755 /tmp/AtomicParsley /usr/local/bin \
  && rm /tmp/AtomicParsley

# Install system dependencies
RUN apk add --no-cache ffmpeg perl-libwww perl-lwp-protocol-https perl-mojolicious perl-xml-libxml

# Install get_iplayer
COPY --from=deps /opt/app/get_iplayer /tmp/get_iplayer
RUN install -m 755 /tmp/get_iplayer /usr/local/bin \
  && rm /tmp/get_iplayer

# Install iPlayer-to-plex
# @link https://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
COPY --from=deps /opt/app/iplayer-to-plex .
RUN apk add --no-cache curl \
  && mkdir /lib64 \
  && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
  && chmod +x ./iplayer-to-plex \
  && apk del curl

USER ${USER_NAME}
ENTRYPOINT [ "./entrypoint.sh" ]
