.PHONY: run build clean test

run:
	go run cmd/server/main.go

build:
	go build -o bin/server cmd/server/main.go

clean:
	rm -rf bin/

test:
	go test ./...

deps:
	go mod download
	go mod tidy
