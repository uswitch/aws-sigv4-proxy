FROM amazonlinux:latest AS build

RUN yum -y update && rm -rf /var/cache/yum/*
RUN yum install -y  \
      ca-certificates \
      git \
      bash \
      go

RUN mkdir /aws-sigv4-proxy
WORKDIR /aws-sigv4-proxy
COPY go.mod .
COPY go.sum .

RUN go env -w GOPROXY=direct
RUN go mod download
COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o /go/bin/aws-sigv4-proxy

FROM alpine:3.16.7
COPY --from=build /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/
COPY --from=build /go/bin/aws-sigv4-proxy /go/bin/aws-sigv4-proxy
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
