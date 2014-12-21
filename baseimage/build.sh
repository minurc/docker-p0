#!/bin/sh

NAME=punkto0/baseimage
VERSION=2014.12.1

git clone https://github.com/phusion/baseimage-docker.git

cd baseimage-docker

make build NAME=$NAME VERSION=$VERSION

make tag_latest NAME=$NAME VERSION=$VERSION


