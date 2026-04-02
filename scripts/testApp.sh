#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  GH actions CI test script
##
##############################################################################

./mvnw -version

./mvnw -ntp -Dhttp.keepAlive=false \
      -Dmaven.wagon.http.pool=false \
      -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
      -q clean package

docker pull -q icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi

docker build -t springboot .
docker run -d --name springBootContainer --rm -p 9080:9080 -p 9443:9443 springboot

sleep 40

status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9080/hello")"
if [ "$status" == "200" ]; then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT NOT OK
  docker exec springBootContainer cat /logs/messages.log
  docker stop springBootContainer
  exit 1
fi

docker exec springBootContainer cat /logs/messages.log | grep product
docker exec springBootContainer cat /logs/messages.log | grep java

docker stop springBootContainer

uname -r
sudo add-apt-repository universe
sudo apt update
sudo add-apt-repository ppa:criu/ppa
sudo apt-get install -y criu
sudo criu check
criu --version
sudo criu check --all
capsh --print 
grep CapEff /proc/1/status
cp ../instantOn/Dockerfile Dockerfile
cat /proc/sys/kernel/yama/ptrace_scope
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
#cat Dockerfile
docker run -d --name springBootCheckpointContainer \
  --privileged \
  --security-opt seccomp=unconfined \
  --security-opt apparmor=unconfined \
  --cap-add=SYS_ADMIN \
  --cap-add=NET_ADMIN \
  --userns=host \
  --network=host \
  --cap-add=CHECKPOINT_RESTORE \
  --cap-add=SYS_PTRACE \
  --cap-add=SETPCAP \
  --pid=host \
  --cgroupns=host \
  --ipc=host \
  -e XDG_RUNTIME_DIR=/tmp \
  -e WLP_CHECKPOINT=afterAppStart \
  springboot

docker ps -a
#docker exec springBootCheckpointContainer bash -C 'id; ls -ld /liberty/logs/checkpoint; touch /liberty/logs/checkpoint/testfile'
docker logs springBootCheckpointContainer
#cat "$GITHUB_WORKSPACE/checkpoint-logs/checkpoint.log"

# docker cp springBootCheckpointContainer:/liberty/logs/checkpoint/checkpoint.log .
# cat checkpoint.log
docker commit springBootCheckpointContainer springboot-instanton
docker stop springBootCheckpointContainer
docker rm springBootCheckpointContainer
docker images
docker run --rm -d \
  --name springBootContainer \
  --cap-add=CHECKPOINT_RESTORE \
  --cap-add=SETPCAP \
  --security-opt seccomp=unconfined \
  -p 9080:9080 \
  springboot-instanton
sleep 40
docker ps -a
docker logs springBootContainer
status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9080/hello")"
docker stop springBootContainer
if [ "$status" == "200" ]; then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT NOT OK
  exit 1
fi

./mvnw -ntp liberty:start
status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9080/hello")"
if [ "$status" == "200" ]; then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT NOT OK
  ./mvnw -ntp liberty:stop
  exit 1
fi
./mvnw -ntp liberty:stop

if [ ! -f "target/GSSpringBootApp.jar" ]; then
  echo "target/GSSpringBootApp.jar was not generated!"
  exit 1
fi

$JAVA_HOME/bin/java -jar target/GSSpringBootApp.jar &
GSSBA_PID=$!
echo "GSSBA_PID=$GSSBA_PID"
sleep 30
status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:9080/hello")"
kill $GSSBA_PID
if [ "$status" == "200" ]; then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT NOT OK
  exit 1
fi
