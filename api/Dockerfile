# Build stage
FROM eclipse-temurin:26-jdk-alpine AS builder

WORKDIR /app
COPY . .
RUN ./mvnw package -DskipTests

# Run stage
FROM eclipse-temurin:26-jdk-alpine AS runner

WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

CMD ["java", "-XX:MaxRAMPercentage=50", "-jar", "app.jar"]
