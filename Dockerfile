# -------- Stage 1: Build WAR --------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy only pom first to leverage Docker cache for dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of the source code
COPY . .

# Build WAR (skip tests to save time)
RUN mvn clean package -DskipTests

# -------- Stage 2: Minimal Tomcat --------
FROM tomcat:9.0.82-jdk17-temurin-focal-slim

# Remove default apps to reduce image size
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from builder stage
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
