pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_TOKEN = credentials('jenkins-sonar')
        GIT_CREDS   = credentials('github-creds')
        DOCKER_HUB_CREDS = credentials('docker-hub-creds')  // Nouveau pour Docker Hub
        IMAGE_NAME = 'khalil1363/esprit-k8s-2025:latest'         // Change par ton pseudo/nom-repo
        IMAGE_TAG = "${env.BUILD_NUMBER}"                  // Tag avec numéro de build
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
        }
     stage(' Docker Login') {
               steps {
                   withCredentials([usernamePassword(
                       credentialsId: 'dockerhub-token',
                       usernameVariable: 'DOCKER_USER',
                       passwordVariable: 'DOCKER_TOKEN'
                   )]) {
                       sh 'echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin'
                   }
               }
           }

           stage('📤 Push Docker Image') {
               steps {
                   sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
               }
           }

           stage('☸️ Deploy to Kubernetes') {
               steps {
                   sh '''
                       kubectl apply -f k8s/
                       kubectl rollout status deployment tpfoyer-deployment
                   '''
               }
           }
       }
        }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline CI réussi '
        }
        failure {
            echo 'Échec du pipeline '
        }
    }
}