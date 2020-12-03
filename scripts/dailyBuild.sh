#!/bin/bash
while getopts t:d:b:u: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    b) BUILD="${OPTARG}" ;;
    u) DOCKER_USERNAME="${OPTARG}" ;;
    esac
done

sed -i "\#<version>3.2<\/version>#,\#<configuration>#c<version>3.2</version><configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/"$DEVDATE"/"$DEVBUILD"</runtimeUrl></install>" pom.xml
cat pom.xml

sed -i "s;FROM openliberty/open-liberty:kernel-java8-openj9-ubi;FROM "$DOCKER_USERNAME"/olguides:'$BUILD';g" Dockerfile
cat Dockerfile

../scripts/testApp.sh
