FROM golang:alpine

USER root

COPY ./go/src/memo_app /go/src/memo_app
WORKDIR /go/src/memo_app
RUN go build -o main
RUN mkdir /app \
  && cp /go/src/memo_app/main /app/main

WORKDIR /
CMD ./app/main
