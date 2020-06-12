---
title: "Docker镜像操作"
date: "2020-06-12"
categories:
    - "技术"
tags:
    - "Docker"
toc: false
indent: false
original: true
---

## 一、docker image

``` zsh
➜  docker image --help

Usage:	docker image COMMAND

Manage images

Commands:
  build       Build an image from a Dockerfile
  history     Show the history of an image
  import      Import the contents from a tarball to create a filesystem image
  inspect     Display detailed information on one or more images
  load        Load an image from a tar archive or STDIN
  ls          List images
  prune       Remove unused images
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rm          Remove one or more images
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

Run 'docker image COMMAND --help' for more information on a command.
```

``` zsh
➜  docker -h
Flag shorthand -h has been deprecated, please use --help

Usage:	docker [OPTIONS] COMMAND

Commands:
  build       Build an image from a Dockerfile
  commit      Create a new image from a container's changes
  history     Show the history of an image
  images      List images
  import      Import the contents from a tarball to create a filesystem image
  load        Load an image from a tar archive or STDIN
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rmi         Remove one or more images
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  search      Search the Docker Hub for images
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

Run 'docker COMMAND --help' for more information on a command.
```
