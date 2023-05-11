FROM maven:3.6.0-jdk-11-slim AS build
WORKDIR /app
COPY src ./src
COPY pom.xml ./
RUN mvn -f /app/pom.xml clean package

FROM openjdk:16-alpine3.13
COPY --from=build /app/target/*.jar /usr/local/lib/my-app-0.0.1-SNAPSHOT.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/local/lib/my-app-0.0.1-SNAPSHOT.jar"]