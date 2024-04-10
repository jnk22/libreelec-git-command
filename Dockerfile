FROM alpine:3.19
LABEL maintainer="Jannik Schäfer"

RUN apk --no-cache add git~=2.43 openssh~=9.6 && rm -rf /var/lib/apt/lists/*

VOLUME /git
WORKDIR /git

ENTRYPOINT ["git"]
CMD ["--help"]
