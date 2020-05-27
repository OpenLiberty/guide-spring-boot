#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

mvn -q clean package

docker pull openliberty/open-liberty:kernel-java8-openj9-ubi

docker build -t springboot .
docker run -d --name springBootContainer -p 9080:9080 -p 9443:9443 springboot

sleep 60

status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9080/hello")" 
if [ "$status" == "200" ]
then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT NOT OK
  exit 1
fi

docker stop springBootContainer
docker rm springBootContainer

mvn liberty:start
curl http://localhost:9080/hello
mvn liberty:stop
if [ ! -f "target/GSSpringBootApp.jar" ]; then
    echo "target/GSSpringBootApp.jar was not generated!"
    exit 1
fi
