FROM       openjdk:17-slim
WORKDIR    /newspace
COPY       ./build/libs/ssom-backend-1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]