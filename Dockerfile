# -------- Stage 1: Build WAR --------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Build WAR
COPY . .
RUN mvn clean package -DskipTests

# -------- Stage 2: Tomcat Runtime --------
FROM tomcat:9.0.115-jdk17-corretto

# Remove default apps to slim down
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR into ROOT.war
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
