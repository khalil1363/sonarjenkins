# Image de base légère avec Java 17
FROM openjdk:17-jdk-slim

# Copie le JAR généré par Maven
COPY target/*.jar app.jar

# Port exposé (change en 8081 ou autre si ton appli utilise un autre port)
EXPOSE 8080

# Commande pour lancer l'appli
ENTRYPOINT ["java", "-jar", "/app.jar"]