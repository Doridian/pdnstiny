FROM alpine:3.22 AS base

RUN apk add --no-cache \
        ca-certificates \
        pdns \
        pdns-backend-bind \
        pdns-backend-lua2 \
        pdns-backend-pipe \
        pdns-backend-remote \
        pdns-backend-sqlite3 \
        pdns-recursor \
        s6

FROM base AS compressor

RUN apk add --no-cache upx

RUN mkdir -p /out && \
    find /usr/bin -type f -name '*pdns*' -print0 | cpio -0dmp /out && \
    echo /usr/bin/rec_control /usr/bin/sqlite3 | cpio -dmp /out && \
    find /usr/sbin -type f -name '*pdns*' -print0 | cpio -0dmp /out && \
    find /out -type f -exec upx --best {} \;

FROM base AS compressed

COPY --from=compressor /out/ /
RUN mv /etc/pdns /etc/pdns-stock && \
    rm -f /etc/pdns-stock/*.conf-dist

FROM scratch AS default

COPY --from=compressed / /
COPY rootfs/ /

VOLUME ["/etc/pdns"]
ENTRYPOINT ["/entrypoint.sh"]
