FROM debian:bullseye

ENV GOLANG_VERSION=1.20.5

RUN apt-get update && \
    apt-get install -y \
    gcc \
    make \
    git \
    curl \
    vim \
    tmux \
    htop \
    unzip \
    ca-certificates \
    && apt-get clean

RUN curl -LO https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz && \
    tar -C /usr/local -xvzf go$GOLANG_VERSION.linux-amd64.tar.gz && \
    rm go$GOLANG_VERSION.linux-amd64.tar.gz

ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

WORKDIR /workspace

EXPOSE 8080

CMD ["bash"]
