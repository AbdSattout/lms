# Build stage
FROM eclipse-temurin:26-jdk-jammy AS builder

WORKDIR /app
COPY . .
RUN ./mvnw package -DskipTests

# Run stage
FROM eclipse-temurin:26-jre-jammy AS runner

WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

CMD ["java", "-XX:+UseSerialGC", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
