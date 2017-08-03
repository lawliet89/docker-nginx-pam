ARG NGINX_VERSION=1.13.3

FROM buildpack-deps:stretch as builder
ARG NGINX_VERSION
ARG NGINX_PAM_VERSION=1.5.1

WORKDIR /build
RUN set -xeu \
    && curl -sSL "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar --strip-components 1 -xz  \
    && git clone https://github.com/sto/ngx_http_auth_pam_module.git -b "v${NGINX_PAM_VERSION}"

RUN set -xeu \
    && apt-get update \
    && apt-get install -y libpam0g-dev

RUN set -xeu \
    && ./configure --add-dynamic-module=/build/ngx_http_auth_pam_module \
    && make modules

FROM nginx:${NGINX_VERSION}-alpine

COPY --from=builder /build/objs/ngx_http_auth_pam_module.so /usr/lib/nginx/modules
