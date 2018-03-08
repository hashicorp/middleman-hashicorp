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

docker-push:
	@echo "==> Pushing to Docker registry..."
	@docker push "hashicorp/middleman-hashicorp:latest"
	@docker push "hashicorp/middleman-hashicorp:${VERSION}"

gem:
	@echo "==> Building and releasing gem v${VERSION}..."
	@rm -rf pkg/
	@bundle exec rake release

release: gem docker docker-push

.PHONY: docker docker-push gem release
