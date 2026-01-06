FROM amazoncorretto:17
ARG JAR_FILE=target/discovery-service-0.0.1-SNAPSHOT.jar
WORKDIR /app
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","app.jar"]
