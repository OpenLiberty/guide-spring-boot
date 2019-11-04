#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

mvn -q clean package
mvn liberty:start
curl http://localhost:9080/hello
mvn liberty:stop
if [ ! -f "target/GSSpringBootApp.jar" ]; then
    echo "target/GSSpringBootApp.jar was not generated!"
    exit 1
fi
