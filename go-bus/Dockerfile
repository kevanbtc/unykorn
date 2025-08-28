FROM golang:1.21-alpine AS build
WORKDIR /app
COPY . .
RUN go build -o /out/iso-bus ./cmd/iso-bus

FROM alpine:3.20
WORKDIR /app
COPY --from=build /out/iso-bus /app/iso-bus
COPY config /app/config
VOLUME ["/data"]
EXPOSE 8080
ENTRYPOINT ["/app/iso-bus", "--config", "/app/config/config.yaml", "--data", "/data"]
