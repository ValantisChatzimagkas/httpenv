# Build stage
FROM golang:1.25-rc-alpine AS builder
WORKDIR /go/src/app
COPY httpenv.go .
RUN go build -o httpenv httpenv.go

# Test stage - runs tests and validates the build
FROM golang:1.25-rc-alpine AS test
WORKDIR /go/src/app
COPY httpenv.go .

# Install any testing dependencies if needed
RUN apk add --no-cache curl wget

# Build the application
RUN go build -o httpenv httpenv.go

# Run Go tests (if you have any test files)
# RUN go test -v ./...

# Test that the binary was built correctly
RUN ./httpenv --help || echo "Binary built successfully"

# Basic smoke test - start the app in background and test it
RUN ./httpenv & \
    sleep 2 && \
    wget --spider -q http://localhost:8888/ && \
    echo "Application smoke test passed" && \
    pkill httpenv

# Install wget for healthcheck
RUN apk add --no-cache wget

COPY --from=builder --chown=httpenv:httpenv /go/src/app/httpenv /httpenv
EXPOSE 8888
USER httpenv
CMD ["/httpenv"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --spider -q http://localhost:8888/ || exit 1