VERSION?=$(shell awk -F\" '/VERSION/ { print $$2; exit }' lib/middleman-hashicorp/version.rb)

docker:
	@echo "==> Building container v${VERSION}..."
	@docker build \
		--build-arg "VERSION=${VERSION}" \
		--label "${VERSION}" \
		--file "docker/Dockerfile" \
		--tag "hashicorp/middleman-hashicorp" \
		--tag "hashicorp/middleman-hashicorp:${VERSION}" \
		--pull \
		--rm \
		$(shell pwd)/docker

gem:
	@echo "==> Building and releasing gem v${VERSION}..."
	@bundle exec rake release

release: gem docker

.PHONY: docker gem release
