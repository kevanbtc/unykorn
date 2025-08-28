.PHONY: all build test lint bus docker release

all: build

build:
	forge build
	cd go-bus && go build ./cmd/iso-bus

test:
	forge test -vv
	cd go-bus && go test ./... -v

lint:
	npm run lint:sol || true
	cd go-bus && golangci-lint run || true

bus:
	cd go-bus && go run ./cmd/iso-bus --config ./config/config.yaml

docker:
	docker build -t ghcr.io/ORG_SLUG/atlas-iso-bus:dev -f go-bus/Dockerfile go-bus

release:
	git tag v$(VER)
	git push origin v$(VER)
