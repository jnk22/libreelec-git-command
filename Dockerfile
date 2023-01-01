FROM alpine
LABEL maintainer="Jannik Schäfer"

RUN apk --no-cache --update add git openssh && \
rm -rf /var/lib/apt/lists/* && \
rm /var/cache/apk/*

VOLUME /git
WORKDIR /git

ENTRYPOINT ["git"]
CMD ["--help"]
