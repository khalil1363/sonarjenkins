# Image de base légère avec Java 17 (recommandée en 2025)
FROM eclipse-temurin:17-jdk-alpine

# Copie le JAR généré par Maven
COPY target/*.jar app.jar

# Port exposé
EXPOSE 8080

# Commande pour lancer l'appli
ENTRYPOINT ["java", "-jar", "/app.jar"]