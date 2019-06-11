# Stage and thin the application 
FROM open-liberty:springBoot2 as staging
COPY --chown=1001:0 ../springbootApp/target/gs-spring-boot-*.jar /staging/gs-spring-boot-fat.jar
RUN springBootUtility thin \
 --sourceAppPath=/staging/gs-spring-boot-fat.jar \
 --targetThinAppPath=/staging/gs-spring-boot-thin.jar \
 --targetLibCachePath=/staging/lib.index.cache

# Build the image only copying the lib.index.cache and the thin application
FROM open-liberty:springBoot2
COPY --chown=1001:0 src/main/liberty/config/server.xml /config
COPY --from=staging /staging/lib.index.cache /lib.index.cache
COPY --from=staging /staging/gs-spring-boot-thin.jar /config/apps/gs-spring-boot-thin.jar
