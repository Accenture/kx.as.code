# syntax=docker/dockerfile:1
# stage 1
FROM docker.io/library/golang:1.20.10-alpine AS build
WORKDIR /app
COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags '-s -w -extldflags "-static"' -o configo main.go

# stage 2
FROM scratch
WORKDIR /app
COPY --from=build /app/configo .

ENTRYPOINT ["./configo"]
# CMD ["--help"]
