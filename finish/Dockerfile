# Stage and thin the application 
# tag::OLimage1[]
FROM open-liberty:springBoot2 as staging
# end::OLimage1[]
# tag::copyJar[]
COPY --chown=1001:0 target/gs-spring-boot-0.1.0.jar \
                    /staging/fat-gs-spring-boot-0.1.0.jar
# end::copyJar[]
# tag::springBootUtility[]
RUN springBootUtility thin \
 --sourceAppPath=/staging/fat-gs-spring-boot-0.1.0.jar \
 --targetThinAppPath=/staging/thin-gs-spring-boot-0.1.0.jar \
 --targetLibCachePath=/staging/lib.index.cache
# end::springBootUtility[]

# Build the image only copying the lib.index.cache and the thin application
# tag::OLimage2[]
FROM open-liberty:springBoot2
# end::OLimage2[]
COPY --chown=1001:0 src/main/liberty/config/server.xml /config
# tag::libcache[]
COPY --from=staging /staging/lib.index.cache /lib.index.cache
# end::libcache[]
# tag::thinjar[]
COPY --from=staging /staging/thin-gs-spring-boot-0.1.0.jar \ 
                    /config/apps/thin-gs-spring-boot-0.1.0.jar
# end::thinjar[]
