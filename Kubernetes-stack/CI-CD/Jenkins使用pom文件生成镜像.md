---
title: "Jenkins使用pom文件生成镜像"
date: "2020-06-12"
categories:
    - "技术"
tags:
    - "Jenkins"
    - "Docker"
    - "CICD"
    - "Maven"
toc: false
indent: false
original: true
draft: true
---

## 一、dockerfile-maven-plugin

### 1、parent pom.xml

``` xml
<project>
  <properties>
    <dockerfile-maven-plugin.version>1.4.12</dockerfile-maven-plugin.version>
  </properties>
  <build>
    <pluginManagement>
      <plugins>

        <plugin>
          <groupId>com.spotify</groupId>
          <artifactId>dockerfile-maven-plugin</artifactId>
          <version>${dockerfile-maven-plugin.version}</version>
          <executions>
            <execution>
              <id>default</id>
              <goals>
                <goal>build</goal>
                <goal>push</goal>
              </goals>
            </execution>
          </executions>
          <configuration>
            <repository>192.168.100.233/library/${project.artifactId}</repository>
            <tag>${project.version}</tag>
            <buildArgs>
              <ARTIFACTID>${project.artifactId}</ARTIFACTID>
              <JAR_FILE>target/${project.build.finalName}.jar</JAR_FILE>
              <COPY_DIR>target/aihangxunxi/</COPY_DIR>
            </buildArgs>
          </configuration>
        </plugin>

      </plugins>
    </pluginManagement>
  </build>
</project>
```

### 2、pom.xml

``` xml
<project>
  <artifactId>info-ad-service</artifactId>
  <version>0.0.1-SNAPSHOT</version>
</project>
```

### 3、Dockerfile

``` Dockerfile
FROM 192.168.100.233/library/amazoncorretto:8.0
MAINTAINER Aihangxunxi<www.aihangxunxi.com>

# Add Maven dependencies (not shaded into the artifact; Docker-cached)
# ADD target/lib           /usr/share/myservice/lib
# Add the service itself
ARG JAR_FILE
ARG ARTIFACTID
ARG COPY_DIR
COPY $COPY_DIR /opt/aihangxunxi
ADD $JAR_FILE /opt/aihangxunxi/lib/${ARTIFACTID}.jar
# ENV APP_ROOT=/opt/aihangxunxi APP_NAME=$ARTIFACTID
EXPOSE 8801
ENTRYPOINT ["/bin/bash", "/opt/aihangxunxi/bin/start.sh", "info-ad-service.jar"]
# CMD ["/bin/sh","-c","java -jar ${APP_ROOT}/lib/${APP_NAME}.jar > ${APP_ROOT}/logs/${APP_NAME}.log 2>&1 &"]
```

## 二、Jenkins

### 2.1

``` maven
-pl info-ad-service -am clean deploy
```
