NAME      := selenium-server
REGISTRY  := whiteplus/$(NAME)
VERSION   := 20170601

.PHONY: build tag push


build:
	cd $(VERSION); docker build -t $(NAME):$(VERSION) .


tag: build
	docker tag $(NAME):$(VERSION) $(REGISTRY):$(VERSION)


push: tag
	docker push $(REGISTRY):$(VERSION)


push-latest: tag
	docker push $(REGISTRY):latest


run:
	docker run -it --rm --shm-size=1024m --cap-add=SYS_ADMIN -p=127.0.0.1:4444:4444 $(NAME):$(VERSION)


bash:
	docker run -it --rm --shm-size=1024m --cap-add=SYS_ADMIN --entrypoint bash $(NAME):$(VERSION)
