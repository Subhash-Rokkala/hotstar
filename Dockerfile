# -------- Stage 1: Build --------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY . .
RUN mvn clean package -DskipTests

# -------- Stage 2: Run (Tomcat) --------
FROM tomcat:9.0-jdk17-temurin

# Remove default apps (optional but clean)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
