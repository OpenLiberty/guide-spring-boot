# Stage and thin the application 
FROM open-liberty:springBoot2 as staging
COPY --chown=1001:0 target/gs-spring-boot-0.1.0.jar \
                    /staging/fat-gs-spring-boot-0.1.0.jar
RUN springBootUtility thin \
 --sourceAppPath=/staging/fat-gs-spring-boot-0.1.0.jar \
 --targetThinAppPath=/staging/thin-gs-spring-boot-0.1.0.jar \
 --targetLibCachePath=/staging/lib.index.cache

# Build the image only copying the lib.index.cache and the thin application
FROM open-liberty:springBoot2
COPY --chown=1001:0 src/main/liberty/config/server.xml /config
COPY --from=staging /staging/lib.index.cache /lib.index.cache
COPY --from=staging /staging/thin-gs-spring-boot-0.1.0.jar /config/apps/thin-gs-spring-boot-0.1.0.jar
