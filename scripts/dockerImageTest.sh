#!/bin/bash
while getopts t:d: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    *) echo "Invalid option";;
    esac
done

echo "Testing latest OpenLiberty Docker image"

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#,\#<configuration>#c<artifactId>liberty-maven-plugin</artifactId><version>3.8.2</version><configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/""$DATE""/""$DRIVER""</runtimeUrl></install>" pom.xml
cat pom.xml

sed -i "s;FROM icr.io/appcafe/open-liberty:full-java17-openj9-ubi;FROM cp.stg.icr.io/cp/olc/open-liberty-daily:full-java17-openj9-ubi;g" Dockerfile
sed -i "s;FROM icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi;FROM cp.stg.icr.io/cp/olc/open-liberty-daily:full-java17-openj9-ubi;g" Dockerfile
sed -i "s;RUN features.sh;#RUN features.sh;g" Dockerfile
cat Dockerfile

echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin cp.stg.icr.io
sudo docker pull -q "cp.stg.icr.io/cp/olc/open-liberty-daily:full-java17-openj9-ubi"
sudo echo "build level:"; docker inspect --format "{{ index .Config.Labels \"org.opencontainers.image.revision\"}}" cp.stg.icr.io/cp/olc/open-liberty-daily:full-java17-openj9-ubi

sudo -E ../scripts/testApp.sh
