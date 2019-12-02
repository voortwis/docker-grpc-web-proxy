# build stage
FROM golang:1.13.4-alpine as builder
LABEL maintainer="voortwis@users.noreply.github.com"

RUN apk update && apk upgrade && \
    apk add --no-cache git openssh openssl gettext

# RUN export GO111MODULE=on && go mod init && go mod vendor && 
RUN go get -u github.com/voortwis/grpc-web/go/grpcwebproxy
RUN mkdir -p /tmp/ \
    && openssl req -new -x509 -sha256 -newkey rsa:2048 -days 365 -nodes -out /tmp/localhost.crt -keyout /tmp/localhost.key -subj "/C=NL/ST=Gelderland/L=Loil/O=tikc/OU=dev/CN=localhost"

# deploy stage
FROM alpine:latest
LABEL maintainer="voortwis@users.noreply.github.com"

COPY --from=builder /go/bin/grpcwebproxy ./
COPY --from=builder /tmp/localhost.crt /tmp/localhost.key ./

CMD [ \
    "./grpcwebproxy", \
    "--backend_addr=server:$BACKEND_ADDR" \
]
