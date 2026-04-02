#!/bin/bash
set -euxo pipefail

APP_IMAGE="localhost/springboot"
INSTANTON_IMAGE="localhost/springboot-instanton"
APP_PORT=9080

./mvnw -version

./mvnw -ntp -Dhttp.keepAlive=false \
  -Dmaven.wagon.http.pool=false \
  -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
  -q clean package

docker pull icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi

# Build the application image
docker build -t "$APP_IMAGE" .

# Start the normal app container and verify it
docker run -d --name springBootContainer \
  -p ${APP_PORT}:9080 \
  "$APP_IMAGE"

sleep 40

status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:${APP_PORT}/hello")"
if [ "$status" = "200" ]; then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT NOT OK
  docker logs springBootContainer
  docker rm -f springBootContainer
  exit 1
fi

#docker logs springBootContainer | grep product
# docker logs springBootContainer | grep java
docker rm -f springBootContainer

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
cat /proc/sys/kernel/yama/ptrace_scope

# Build the InstantOn-ready image if your Dockerfile uses checkpoint.sh
podman build -t "$APP_IMAGE" .

# Run the checkpoint container
podman run -d --name springBootCheckpointContainer \
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
  "$APP_IMAGE"

podman ps -a
podman logs springBootCheckpointContainer

podman commit springBootCheckpointContainer "$INSTANTON_IMAGE"
podman stop springBootCheckpointContainer
podman rm springBootCheckpointContainer
podman images

# Run the committed InstantOn image
podman run -d --name springBootContainer \
  --cap-add=CHECKPOINT_RESTORE \
  --cap-add=SETPCAP \
  --security-opt seccomp=unconfined \
  -p ${APP_PORT}:9080 \
  "$INSTANTON_IMAGE"

sleep 40
podman ps -a
podman logs springBootContainer

status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:${APP_PORT}/hello")"
if [ "$status" = "200" ]; then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT NOT OK
  podman logs springBootContainer
  podman rm -f springBootContainer
  exit 1
fi

podman rm -f springBootContainer

./mvnw -ntp liberty:start
status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:${APP_PORT}/hello")"
if [ "$status" = "200" ]; then
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

"$JAVA_HOME/bin/java" -jar target/GSSpringBootApp.jar &
GSSBA_PID=$!
echo "GSSBA_PID=$GSSBA_PID"
sleep 30

status="$(curl --write-out "%{http_code}\n" --silent --output /dev/null "http://localhost:${APP_PORT}/hello")"
kill "$GSSBA_PID"

if [ "$status" = "200" ]; then
  echo ENDPOINT OK
else
  echo "$status"
  echo ENDPOINT NOT OK
  exit 1
fi