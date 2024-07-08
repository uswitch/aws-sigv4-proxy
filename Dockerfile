FROM amazonlinux:2 AS build

RUN yum -y update && rm -rf /var/cache/yum/*
RUN yum install -y  \
      ca-certificates \
      git \
      bash \
      go

FROM alpine:3
COPY --from=build /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/
COPY --chmod=755 bin/aws-sigv4-proxy /aws-sigv4-proxy
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
