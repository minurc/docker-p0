NAME = punkto0/backup
VERSION = 2015.1.12

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm image

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest


