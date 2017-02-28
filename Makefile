IMAGE    ?= steigr/link-manager
VERSION  ?= $(shell git branch | grep \* | cut -d ' ' -f2)
BASE     ?= busybox

all: image
	@true

image:
	@sed 's#^FROM .*#FROM $(BASE)#' Dockerfile > Dockerfile.build
	[[ "$(NO_PULL)" ]] || docker pull $$(grep ^FROM Dockerfile.build | awk '{print $$2}')
	docker build --tag=$(IMAGE):$(VERSION) --file=Dockerfile.build .
	@rm Dockerfile.build

run: image
	docker run --rm --env=TRACE --name=$(shell basename $(IMAGE)) $(IMAGE):$(VERSION)
