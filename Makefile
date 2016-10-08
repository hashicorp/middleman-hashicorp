VERSION?=$(shell awk -F\" '/VERSION/ { print $$2; exit }' lib/middleman-hashicorp/version.rb)

docker:
	@echo "==> Building container v${VERSION}..."
	@docker build \
		--file "docker/Dockerfile" \
		--tag "hashicorp/middleman-hashicorp" \
		--tag "hashicorp/middleman-hashicorp:${VERSION}" \
		--pull \
		--rm \
		.

gem:
	@echo "==> Building and releasing gem v${VERSION}..."
	@rm -rf pkg/
	@bundle exec rake release

release: gem docker

.PHONY: docker gem release
