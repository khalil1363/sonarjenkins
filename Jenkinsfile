pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_TOKEN = credentials('jenkins-sonar')
        GIT_CREDS   = credentials('github-creds')
        IMAGE_NAME = 'khalil1363/sonarjenkins-app'         // Change par ton pseudo/nom-repo
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
      stage('Build Docker Image') {
                  steps {
                      sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                      sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                  }
              }

              stage('Push to Docker Hub') {
                  steps {
                      sh 'echo $DOCKER_HUB_CREDS_PSW | docker login -u $DOCKER_HUB_CREDS_USR --password-stdin'
                      sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                      sh "docker push ${IMAGE_NAME}:latest"
                  }
              }

              stage('Cleanup Local Images') {
                  steps {
                      sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
                      sh "docker rmi ${IMAGE_NAME}:latest || true"
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