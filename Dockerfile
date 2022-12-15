FROM golang:1.19-alpine AS builder

LABEL maintainer "Derek Collison <derek@nats.io>"
LABEL maintainer "Waldemar Quevedo <wally@nats.io>"

WORKDIR $GOPATH/src/github.com/nats-io/

RUN apk add -U --no-cache git binutils

RUN go install github.com/nats-io/nats-top@v0.5.3

RUN go install -ldflags="-X main.version=2.7.6" github.com/nats-io/nsc/v2@v2.7.6

RUN go install github.com/nats-io/natscli/nats@v0.0.35

RUN go install github.com/nats-io/stan.go/examples/stan-pub@latest
RUN go install github.com/nats-io/stan.go/examples/stan-sub@latest
RUN go install github.com/nats-io/stan.go/examples/stan-bench@latest

FROM alpine:3.17.0

RUN apk add -U --no-cache ca-certificates figlet jq

COPY --from=builder /go/bin/* /usr/local/bin/

RUN cd /usr/local/bin/ && \
    ln -s nats-box nats-pub && \
    ln -s nats-box nats-sub && \
    ln -s nats-box nats-req && \
    ln -s nats-box nats-rply

WORKDIR /root

USER root

ENV NKEYS_PATH /nsc/nkeys
ENV XDG_DATA_HOME /nsc
ENV XDG_CONFIG_HOME /nsc/.config

COPY .profile $WORKDIR

ENTRYPOINT ["/bin/sh", "-l"]
