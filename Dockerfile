FROM ubuntu:18.04

LABEL maintainer="Petr Ruzicka <petr.ruzicka@gmail.com>"
LABEL "com.github.actions.name"="Broknen Link Checker"
LABEL "com.github.actions.description"="Check broken links on web pages stored locally or remotely"
LABEL "com.github.actions.icon"="activity"
LABEL "com.github.actions.color"="blue"

#ENV MUFFET_VERSION="1.3.2"
ENV MUFFET_VERSION="latest"

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends bash ca-certificates sudo wget && \
    && apt-get clean && \
    && rm -rf /var/lib/apt/lists/* && \
    if [ "${MUFFET_VERSION}" = "latest" ]; then \
      MUFFET_URL=$(wget --quiet https://api.github.com/repos/raviqqe/muffet/releases/latest -O - | grep "browser_download_url.*muffet_.*_Linux_x86_64.tar.gz" | cut -d \" -f 4) ; \
    else \
      MUFFET_URL="https://github.com/raviqqe/muffet/releases/download/${MUFFET_VERSION}/muffet_${MUFFET_VERSION}_Linux_x86_64.tar.gz" ; \
    fi && \
    wget --quiet "${MUFFET_URL}" -O - | tar xvzf - -C /usr/local/bin/ muffet && \
    wget -qO- https://getcaddy.com | bash -s personal

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
