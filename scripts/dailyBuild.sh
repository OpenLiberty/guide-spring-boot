#!/bin/bash
while getopts t:d:b:u: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    b) BUILD="${OPTARG}" ;;
    u) DOCKER_USERNAME="${OPTARG}" ;;
    *) echo "Invalid option";;
    esac
done

echo "Testing daily build image"

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#,\#<configuration>#c<artifactId>liberty-maven-plugin</artifactId><version>3.8.2</version><configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install>" pom.xml
cat pom.xml

sed -i "s;FROM icr.io/appcafe/open-liberty:full-java17-openj9-ubi;FROM $DOCKER_USERNAME/olguides:$BUILD;g" Dockerfile
sed -i "s;FROM icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi;FROM $DOCKER_USERNAME/olguides:$BUILD;g" Dockerfile
sed -i "s;RUN features.sh;#RUN features.sh;g" Dockerfile
cat Dockerfile

sudo ../scripts/testApp.sh
