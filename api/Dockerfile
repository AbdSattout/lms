# ---------- Build stage ----------
FROM maven:3.9-eclipse-temurin-26 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B dependency:go-offline
COPY src ./src
RUN mvn -B clean package -DskipTests
# ---------- Runtime stage ----------
FROM eclipse-temurin:26-jre
WORKDIR /app
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
RUN groupadd -r spring && useradd -r -g spring spring
USER spring
COPY --from=build /app/target/*.jar app.jar
ENTRYPOINT ["sh", "-c", "${JAVA_HOME}/bin/java -Xms128m -Xmx220m -XX:MaxMetaspaceSize=160m -XX:TieredStopAtLevel=1 -Xss256k -XX:+UseSerialGC -XX:CICompilerCount=1 -Dserver.port=${PORT} -jar app.jar"]
