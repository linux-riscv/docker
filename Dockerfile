FROM ubuntu:mantic

ENV DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "--login", "-e", "-o", "pipefail", "-c" ]
WORKDIR /tmp

COPY setup-github-ubuntu.sh /usr/local/bin/setup-ubuntu.sh
RUN bash /usr/local/bin/setup-ubuntu.sh
