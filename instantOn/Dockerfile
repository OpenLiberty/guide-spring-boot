# Stage: Build CRIU 4.2 from source on UBI (same glibc as runtime image)
FROM registry.access.redhat.com/ubi9/ubi AS criu-builder
RUN dnf install -y gcc make pkg-config \
    protobuf-c-devel protobuf-devel \
    libcap-devel libnl3-devel libnet-devel \
    libaio-devel gnutls-devel python3-protobuf \
    git nftables-devel iptables-devel \
    && dnf clean all
RUN git clone --depth 1 --branch v4.2 https://github.com/checkpoint-restore/criu.git /criu \
WORKDIR /criu
RUN make "-j$(nproc)" && make install PREFIX=/usr/local
# Stage: Thin the application
FROM icr.io/appcafe/open-liberty:full-java21-openj9-ubi-minimal AS staging
COPY --chown=1001:0 target/guide-spring-boot-0.1.0.jar \
                    /staging/fat-guide-spring-boot-0.1.0.jar
RUN springBootUtility thin \
 --sourceAppPath=/staging/fat-guide-spring-boot-0.1.0.jar \
 --targetThinAppPath=/staging/thin-guide-spring-boot-0.1.0.jar \
 --targetLibCachePath=/staging/lib.index.cache
# Stage: Build the final image
FROM icr.io/appcafe/open-liberty:kernel-slim-java21-openj9-ubi-minimal
# Replace CRIU 4.1 with 4.2
USER root
COPY --from=criu-builder /usr/local/sbin/criu /usr/local/sbin/criu
COPY --from=criu-builder /usr/local/lib/libcriu.so.2* /usr/local/lib64/
COPY --from=criu-builder /usr/local/lib/libcompel.so* /usr/local/lib64/
RUN ldconfig && /usr/local/sbin/criu --version
USER 1001
ARG VERSION=1.0
ARG REVISION=SNAPSHOT
LABEL \
  org.opencontainers.image.authors="Your Name" \
  org.opencontainers.image.vendor="Open Liberty" \
  org.opencontainers.image.url="local" \
  org.opencontainers.image.source="https://github.com/OpenLiberty/guide-spring-boot" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$REVISION" \
  vendor="Open Liberty" \
  name="hello app" \
  version="$VERSION-$REVISION" \
  summary="The hello application from the Spring Boot guide" \
  description="This image contains the hello application running with the Open Liberty runtime."
RUN cp /opt/ol/wlp/templates/servers/springBoot3/server.xml /config/server.xml
COPY --chown=1001:0 src/main/liberty/instantOn/crac.xml \
                    /config/configDropins/defaults/crac.xml
RUN features.sh
COPY --chown=1001:0 --from=staging /staging/lib.index.cache /lib.index.cache
COPY --chown=1001:0 --from=staging /staging/thin-guide-spring-boot-0.1.0.jar \
                    /config/dropins/spring/thin-guide-spring-boot-0.1.0.jar
RUN configure.sh