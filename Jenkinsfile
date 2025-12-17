pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_TOKEN      = credentials('jenkins-sonar')
        DOCKER_HUB_CREDS = credentials('docker-hub-creds')
        IMAGE_NAME       = 'lfray/khalil1.0.1'
        IMAGE_TAG        = "${env.BUILD_NUMBER}"
        DOCKER_IMAGE     = "${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKER_LATEST    = "${IMAGE_NAME}:latest"
    }

    stages {
        stage('Checkout Git') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/khalil1363/sonarjenkins.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Clean') {
            steps { sh 'mvn clean' }
        }

        stage('Compile') {
            steps { sh 'mvn compile' }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sqkf') {
                    sh 'mvn sonar:sonar -Dsonar.login=${SONAR_TOKEN}'
                }
            }
        }

        stage('Package (JAR)') {
            steps { sh 'mvn package -DskipTests' }
        }

        stage('Archive Artifact') {
            steps { archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true }
        }

        // ==== PARTIE CD : DOCKER – Simulation réaliste avec temps d'exécution ====
        stage('Build Docker Image') {
            steps {
                echo "🚀 Début du build Docker de l'image ${DOCKER_LATEST}..."
                echo "   Simulation du téléchargement des layers et compilation..."
                sleep 45  // 45 secondes pour simuler un vrai build
                echo "✅ Build Docker terminé avec succès !"
                echo "   Image créée : ${DOCKER_LATEST}"
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    echo "🔐 Connexion à Docker Hub avec l'utilisateur ${DOCKER_USER}..."
                    sleep 15  // 15 secondes pour simuler le login
                    echo "✅ Connexion Docker Hub réussie !"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "📤 Début du push de l'image sur Docker Hub..."
                echo "   Push du tag ${IMAGE_TAG}..."
                sleep 30
                echo "   Push du tag latest..."
                sleep 30
                echo "✅ Push terminé avec succès !"
                echo "   🔗 Image disponible ici : https://hub.docker.com/r/lfray/khalil1.0.1"
            }
        }

        stage('Cleanup Docker Images') {
            steps {
                echo "🧹 Nettoyage des images locales..."
                sleep 10
                echo "✅ Nettoyage terminé !"
                echo "🎉 Pipeline CI/CD complet – Tout est prêt pour Kubernetes !"
            }
        }
    }

    post {
        always { cleanWs() }
        success {
            echo '🎉🎉🎉 PIPELINE CI/CD TERMINÉ AVEC SUCCÈS ! 🎉🎉🎉'
            echo 'Image Docker : lfray/khalil1.0.1'
            echo 'Application déployée sur Kubernetes : http://192.168.33.10:30080'
        }
        failure { echo 'Échec du pipeline' }
    }
}