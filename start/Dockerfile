FROM tjwatson/ol:springboot2 as staging

# Stage the fat JAR
COPY target/gs-spring-boot-*.jar /staging/gs-spring-boot-fat.jar

# Thin the fat application; stage the thin app output and the library cache
RUN springBootUtility thin \
 --sourceAppPath=/staging/gs-spring-boot-fat.jar \
 --targetThinAppPath=/staging/gs-spring-boot-thin.jar \
 --targetLibCachePath=/staging/lib.index.cache

# Final stage, only copying the lib.index.cache and thin application
FROM tjwatson/ol:springboot2

COPY --from=staging /staging/lib.index.cache /lib.index.cache

COPY --from=staging /staging/gs-spring-boot-thin.jar /config/dropins/spring/gs-spring-boot-thin.jar