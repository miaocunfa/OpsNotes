---
title: "Kubernetes之资源限制"
date: "2020-06-30"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "容器化"
    - "资源限制"
toc: false
indent: false
original: true
---

## 一、资源限制

容器的资源需求，资源限制

requests: 需求，最低保障
limits：  限制，硬限制

CPU：
1颗逻辑CPU = 1000微核
500m=0.5CPU

### Usage

``` zsh
kubectl explain deploy.spec.template.spec.containers.resources
KIND:     Deployment
VERSION:  apps/v1

RESOURCE: resources <Object>

DESCRIPTION:
     Compute Resources required by this container. Cannot be updated. More info:
     https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/

     ResourceRequirements describes the compute resource requirements.

FIELDS:
   limits	<map[string]string>
     Limits describes the maximum amount of compute resources allowed. More
     info:
     https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/

   requests	<map[string]string>
     Requests describes the minimum amount of compute resources required. If
     Requests is omitted for a container, it defaults to Limits if that is
     explicitly specified, otherwise to an implementation-defined value. More
     info:
     https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/

```
