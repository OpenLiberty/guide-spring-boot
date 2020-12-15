#!/bin/bash
while getopts t:d:b:u: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    b) BUILD="${OPTARG}" ;;
    u) DOCKER_USERNAME="${OPTARG}" ;;
    esac
done

echo "Testing daily build image"

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#,\#<configuration>#c<artifactId>liberty-maven-plugin</artifactId><version>3.2.3</version><configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/"$DATE"/"$DRIVER"</runtimeUrl></install>" pom.xml
cat pom.xml

sed -i "s;FROM openliberty/open-liberty:kernel-java8-openj9-ubi;FROM "$DOCKER_USERNAME"/olguides:"$BUILD";g" Dockerfile
cat Dockerfile

sudo ../scripts/testApp.sh

echo "Testing daily Docker image"

sed -i "s;FROM "$DOCKER_USERNAME"/olguides:"$BUILD";FROM openliberty/daily:latest;g" Dockerfile
cat Dockerfile

docker pull "openliberty/daily:latest"

IMAGEBUILDLEVEL=$(docker inspect --format "{{ index .Config.Labels \"org.opencontainers.image.revision\"}}" openliberty/daily:latest)

if [ $IMAGEBUILDLEVEL == $BUILD ] 
then
    sudo ../scripts/testApp.sh
else
    echo "Image does not match input build level for testing"
fi
