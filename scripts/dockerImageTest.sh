#!/bin/bash
while getopts t:d:v: flag; do
    case "${flag}" in
    t) DATE="${OPTARG}" ;;
    d) DRIVER="${OPTARG}" ;;
    v) OL_LEVEL="${OPTARG}";;
    *) echo "Invalid option";;
    esac
done

echo "Testing latest OpenLiberty Docker image"

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#,\#<configuration>#c<artifactId>liberty-maven-plugin</artifactId><version>3.8.2</version><configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/""$DATE""/""$DRIVER""</runtimeUrl></install>" pom.xml
cat pom.xml

if [[ "$OL_LEVEL" != "" ]]; then
  sed -i "s;FROM icr.io/appcafe/open-liberty:full-java21-openj9-ubi-minimal;FROM cp.stg.icr.io/cp/olc/open-liberty-vnext:$OL_LEVEL-full-java21-openj9-ubi-minimal;g" Dockerfile
  sed -i "s;FROM icr.io/appcafe/open-liberty:kernel-slim-java21-openj9-ubi-minimal;FROM cp.stg.icr.io/cp/olc/open-liberty-vnext:$OL_LEVEL-full-java21-openj9-ubi-minimal;g" Dockerfile
else
  sed -i "s;FROM icr.io/appcafe/open-liberty:full-java21-openj9-ubi-minimal;FROM cp.stg.icr.io/cp/olc/open-liberty-daily:full-java21-openj9-ubi-minimal;g" Dockerfile
  sed -i "s;FROM icr.io/appcafe/open-liberty:kernel-slim-java21-openj9-ubi-minimal;FROM cp.stg.icr.io/cp/olc/open-liberty-daily:full-java21-openj9-ubi-minimal;g" Dockerfile
fi
sed -i "s;RUN features.sh;#RUN features.sh;g" Dockerfile
cat Dockerfile

echo "$DOCKER_PASSWORD" | sudo docker login -u "$DOCKER_USERNAME" --password-stdin cp.stg.icr.io
if [[ "$OL_LEVEL" != "" ]]; then
  sudo docker pull -q "cp.stg.icr.io/cp/olc/open-liberty-vnext:$OL_LEVEL-full-java21-openj9-ubi-minimal"
  sudo echo "build level:"; docker inspect --format "{{ index .Config.Labels \"org.opencontainers.image.revision\"}}" cp.stg.icr.io/cp/olc/open-liberty-vnext:$OL_LEVEL-full-java21-openj9-ubi-minimal
else
  sudo docker pull -q "cp.stg.icr.io/cp/olc/open-liberty-daily:full-java21-openj9-ubi-minimal"
  sudo echo "build level:"; docker inspect --format "{{ index .Config.Labels \"org.opencontainers.image.revision\"}}" cp.stg.icr.io/cp/olc/open-liberty-daily:full-java21-openj9-ubi-minimal
fi

sudo -E ../scripts/testApp.sh
