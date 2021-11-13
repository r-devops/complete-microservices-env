#!/bin/bash

type mvn
if [ $? -ne 0 ]; then
  curl -s https://raw.githubusercontent.com/linuxautomations/labautomation/master/tools/maven/install-jdk11.sh | bash
fi
mvn -Dmaven.test.skip clean package
export SPRING_PROFILES_ACTIVE=prod
java -jar target/frontend-0.0.1-SNAPSHOT.jar
