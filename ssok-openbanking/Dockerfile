FROM       openjdk:17-slim
WORKDIR    /newspace
COPY       ./build/libs/ssok-openbanking-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]