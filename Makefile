IMAGE    ?= steigr/link-manager
VERSION  ?= $(shell git branch | grep \* | cut -d ' ' -f2)
BASE     ?= scratch

all: image
	@true

image:
	docker build --tag=$(IMAGE):$(VERSION) .

run: image
	docker run --rm --env=TRACE --name=$(shell basename $(IMAGE)) $(IMAGE):$(VERSION)
