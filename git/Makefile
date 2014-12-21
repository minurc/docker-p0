NAME = punkto0/git
VERSION = 2014.12.1

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm image

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest


