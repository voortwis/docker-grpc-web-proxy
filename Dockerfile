# build stage
FROM golang:1.13.4-alpine as builder
LABEL maintainer="esplo@users.noreply.github.com"

RUN apk update && apk upgrade && \
    apk add --no-cache git openssh openssl gettext

RUN export GO111MODULE=on && go mod init && go mod vendor && go get -u github.com/improbable-eng/grpc-web/go/grpcwebproxy

# deploy stage
FROM alpine:latest
LABEL maintainer="klaasjan@voortwis.nl"

COPY --from=builder /go/bin/grpcwebproxy .

CMD [ \
    "./grpcwebproxy", \
    "--backend_addr=server:$BACKEND_ADDR" \
]
