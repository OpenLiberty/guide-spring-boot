#!/bin/bash
while getopts t:d:b:u:j: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    b) BUILD="${OPTARG}" ;;
    u) DOCKER_USERNAME="${OPTARG}" ;;
    j) JDK_LEVEL="${OPTARG}" ;;
    *) echo "Invalid option";;
    esac
done

echo "Testing daily build image"

if [ "$JDK_LEVEL" == "11" ]; then
    echo "Test skipped because the guide does not support Java 11."
    exit 0
fi

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#,\#<configuration>#c<artifactId>liberty-maven-plugin</artifactId><version>3.10</version><configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/$DATE/$DRIVER</runtimeUrl></install>" pom.xml
cat pom.xml

if [[ "$DOCKER_USERNAME" != "" ]]; then
    sed -i "s;FROM icr.io/appcafe/open-liberty:full-java17-openj9-ubi;FROM $DOCKER_USERNAME/olguides:$BUILD-java17;g" Dockerfile
    sed -i "s;FROM icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi;FROM $DOCKER_USERNAME/olguides:$BUILD-java17;g" Dockerfile
    sed -i "s;RUN features.sh;#RUN features.sh;g" Dockerfile
    cat Dockerfile
fi

sudo -E ../scripts/testApp.sh
