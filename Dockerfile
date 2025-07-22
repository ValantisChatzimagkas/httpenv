FROM golang:1.25-rc-alpine
COPY httpenv.go /go
RUN go build httpenv.go

FROM alpine:3.22
RUN addgroup -g 1000 httpenv \
    && adduser -u 1000 -G httpenv -D httpenv
COPY --from=0 --chown=httpenv:httpenv /go/httpenv /httpenv
EXPOSE 8888
# we're not changing user in this example, but you could:
USER httpenv
CMD ["/httpenv"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --spider -q http://localhost:8888/ || exit 1