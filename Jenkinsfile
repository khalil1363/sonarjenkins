pipeline {
    agent any

    tools {
        maven 'M2_HOME'    // Nom de ton installation Maven dans Jenkins (vérifie dans Global Tool Configuration)
        jdk 'JAVA_HOME'        // Nom de ton installation Java dans Jenkins
    }

    environment {
        SONAR_TOKEN = credentials('jenkins-sonar') // ID du credential SonarQube dans Jenkins
        GIT_CREDS   = credentials('github-creds') // ID du credential Git dans Jenkins
    }

    stages {
        stage('Checkout Git') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/khalil1363/sonarjenkins.git',  // Remplace par TON URL GitHub
                    credentialsId: 'github-creds'  // ID de tes creds Git
            }
        }

        stage('Clean') {
            steps {
                sh 'mvn clean'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sqkf') {  // Nom de ton serveur SonarQube configuré dans Jenkins
                    sh 'mvn sonar:sonar -Dsonar.login=${SONAR_TOKEN}'
                }
            }
        }

        stage('Package (JAR)') {
            steps {
                sh 'mvn package -DskipTests'  // Skip tests pour tester vite, enlève si tu as des tests
            }
        }

        // Optionnel : Archive le JAR pour le voir dans Jenkins
        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
            }
        }
    }

    post {
        always {
            cleanWs()  // Nettoie l'espace de travail
        }
        success {
            echo 'Pipeline CI réussi !'
        }
        failure {
            echo 'Échec du pipeline :('
        }
    }
}