FROM alpine:latest as downloader
ENV VERSION=4.16
WORKDIR /workspace
RUN apk add curl
RUN curl -LJO https://github.com/rofl0r/proxychains-ng/releases/download/v${VERSION}/proxychains-ng-${VERSION}.tar.xz && tar -xf proxychains-ng-${VERSION}.tar.xz && mv proxychains-ng-${VERSION} proxychains-ng

FROM ubuntu:22.04 as builder
WORKDIR /proxychains-ng
COPY --from=downloader /workspace/proxychains-ng .
RUN apt update && apt install gcc make -y && mkdir ./etc && ./configure --prefix=./ --sysconfdir=./etc && make && make install && make install-config

FROM ubuntu:22.04
WORKDIR /proxychains-ng
COPY --from=builder /proxychains-ng/bin/* .
COPY --from=builder /proxychains-ng/lib/* .
COPY --from=builder /proxychains-ng/etc/* ./etc/
ENTRYPOINT ["/proxychains-ng/proxychains4"]
