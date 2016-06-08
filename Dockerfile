FROM mitchty/alpine-ghc

RUN apk add --update build-base
RUN apk add --update zlib-dev

ADD stack.yaml .
ADD servant3.cabal .

RUN stack install --only-dependencies

ADD . .

RUN stack build
RUN stack install

EXPOSE 8080

CMD ["/root/.local/bin/servant3-exe"]
