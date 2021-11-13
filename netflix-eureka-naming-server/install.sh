#!/bin/bash
curl -s https://raw.githubusercontent.com/linuxautomations/labautomation/master/tools/maven/install-jdk11.sh | bash
mvn clean package
java -jar target/netflix-eureka-naming-server-0.0.1-SNAPSHOT.jar
