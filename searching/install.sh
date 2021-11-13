#!/bin/bash

type mvn
if [ $? -ne 0 ]; then
  curl -s https://raw.githubusercontent.com/linuxautomations/labautomation/master/tools/maven/install-jdk11.sh | bash
fi
mvn clean package
export SPRING_PROFILES_ACTIVE=prod
java -jar target/searching-service-0.0.1-SNAPSHOT.jar
