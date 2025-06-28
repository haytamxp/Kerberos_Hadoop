FROM alpine:latest

RUN apk add --no-cache openssh && \
    addgroup -g 1001 hadoopadmin && \
    adduser -D -u 1001 -G hadoopadmin hadoopadmin

USER 1001:1001

ENTRYPOINT ["sh", "-c"]
