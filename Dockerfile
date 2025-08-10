# Copyright 2023-2025 Sergei Agibalov
# Copyright 2018-2020 Artem B. Smirnov
# Copyright 2018 Jon Azpiazu
# Copyright 2016 Bryan J. Hong
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

FROM debian:trixie-slim

LABEL maintainer="urpylka@gmail.com"

ARG DEBIAN_FRONTEND=noninteractive \
    VER_APTLY
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    --mount=type=tmpfs,target=/root/.launchpadlib \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/tmp \
  set -eux; \
  apt -q update && apt upgrade -y; \
  apt -y --no-install-recommends --no-install-suggests install \
    graphviz \
    supervisor \
    curl \
    apt-utils \
    gettext-base \
    bash-completion \
    gpg-agent \
    ca-certificates \
    rng-tools; \
  echo "if ! shopt -oq posix; then\n\
  if [ -f /usr/share/bash-completion/bash_completion ]; then\n\
    . /usr/share/bash-completion/bash_completion\n\
  elif [ -f /etc/bash_completion ]; then\n\
    . /etc/bash_completion\n\
  fi\n\
fi" >> /etc/bash.bashrc;

ENV GNUPGHOME="/opt/aptly/gpg" \
    NGINX_CLIENT_MAX_BODY_SIZE=100M

COPY ./rootfs/ /

# Install Aptly
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    --mount=type=tmpfs,target=/root/.launchpadlib \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/tmp \
  set -eux; \
  mkdir -p /etc/apt/keyrings && chmod 755 /etc/apt/keyrings; \
  curl -sLo /etc/apt/keyrings/aptly.asc http://www.aptly.info/pubkey.txt; \
  echo "deb [signed-by=/etc/apt/keyrings/aptly.asc] http://repo.aptly.info/release trixie main" >> /etc/apt/sources.list.d/aptly.list; \
  apt -q update && apt -y --no-install-recommends --no-install-suggests install aptly=${VER_APTLY};

# Configure Nginx
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    --mount=type=tmpfs,target=/root/.launchpadlib \
    --mount=type=tmpfs,target=/var/cache \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/tmp \
  set -eux; \
  apt -q update && apt -y install nginx; \
  rm /etc/nginx/sites-enabled/*

# Declare ports in use
EXPOSE 80 8080

WORKDIR /opt/aptly

ENTRYPOINT [ "/docker-entrypoint.sh" ]
