pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_TOKEN      = credentials('jenkins-sonar')
        DOCKER_HUB_CREDS = credentials('docker-hub-creds')
        IMAGE_NAME       = 'lfray/khalil1.0.1:latest'      // Ton repo Docker Hub
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
                withSonarQubeEnv('sqkf') {
                    sh 'mvn sonar:sonar -Dsonar.login=${SONAR_TOKEN}'
                }
            }
        }

        stage('Package (JAR)') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
            }
        }

        // ==== PARTIE CD : DOCKER ====
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
                sh "docker tag ${DOCKER_IMAGE} ${DOCKER_LATEST}"
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh 'echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh "docker push ${DOCKER_IMAGE}"
                sh "docker push ${DOCKER_LATEST}"
            }
        }

        stage('Cleanup Docker Images') {
            steps {
                sh "docker rmi ${DOCKER_IMAGE} || true"
                sh "docker rmi ${DOCKER_LATEST} || true"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline CI/CD complet réussi ! Image Docker poussée sur    Docker Hub'
        }
        failure {
            echo 'Échec du pipeli'
        }
    }
}