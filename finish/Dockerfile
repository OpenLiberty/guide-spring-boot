# Stage and thin the application 
# tag::OLimage1[]
FROM open-liberty as staging
# end::OLimage1[]

ARG VERSION=1.0
ARG REVISION=SNAPSHOT

LABEL \
  org.opencontainers.image.authors="My Name" \
  org.opencontainers.image.vendor="Open Liberty" \
  org.opencontainers.image.url="local" \
  org.opencontainers.image.source="https://github.com/OpenLiberty/guide-spring-boot" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$REVISION" \
  vendor="Open Liberty" \
  name="staging" \
  version="$VERSION-$REVISION" \
  summary="The first stage of the multistage build from the Spring Boot guide" \
  description="This image contains the Spring Boot application jar file and uses Open Liberty springBootUtility command to thin the application."

# tag::copyJar[]
COPY --chown=1001:0 target/guide-spring-boot-0.1.0.jar \
                    /staging/fat-guide-spring-boot-0.1.0.jar
# end::copyJar[]

# tag::springBootUtility[]
RUN springBootUtility thin \
 --sourceAppPath=/staging/fat-guide-spring-boot-0.1.0.jar \
 --targetThinAppPath=/staging/thin-guide-spring-boot-0.1.0.jar \
 --targetLibCachePath=/staging/lib.index.cache
# end::springBootUtility[]

# Build the image
# tag::OLimage2[]
FROM open-liberty
# end::OLimage2[]

ARG VERSION=1.0
ARG REVISION=SNAPSHOT

LABEL \
  org.opencontainers.image.authors="My Name" \
  org.opencontainers.image.vendor="Open Liberty" \
  org.opencontainers.image.url="local" \
  org.opencontainers.image.source="https://github.com/guide-spring-boot" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$REVISION" \
  vendor="Open Liberty" \
  name="templates" \
  version="$VERSION-$REVISION" \
  summary="The second stage of the multistage build from the Spring Boot guide" \
  description="This image contains the configuration file and Spring Boot dependent library JAR files."

# tag::serverXml[]
RUN cp /opt/ol/wlp/templates/servers/springBoot2/server.xml /config/server.xml
# end::serverXml[]

# tag::libcache[]
COPY --chown=1001:0 --from=staging /staging/lib.index.cache /lib.index.cache
# end::libcache[]
# tag::thinjar[]
COPY --chown=1001:0 --from=staging /staging/thin-guide-spring-boot-0.1.0.jar \
                    /config/dropins/spring/thin-guide-spring-boot-0.1.0.jar
# end::thinjar[]

RUN configure.sh 
