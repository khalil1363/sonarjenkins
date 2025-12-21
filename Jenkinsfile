pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_TOKEN = credentials('jenkins-sonar')
        GIT_CREDS   = credentials('github-creds')
        DOCKER_CREDS   = credentials('docker-hub-creds')  // Docker Hub credentials
        DOCKER_IMAGE  = 'lfray/sonarjenkins'
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
        stage('Docker Build') {
                    steps {
                        sh "docker build -t ${DOCKER_IMAGE}:latest ."
                    }
                }

                stage('Docker Push') {
                    steps {
                        withCredentials([usernamePassword(
                            credentialsId: 'docker-hub-creds',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            sh """
                                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                                docker push ${DOCKER_IMAGE}:latest
                            """
                        }
                    }
                }

            stage('Deploy to Kubernetes') {
                        steps {
                            sh 'kubectl apply -f k8s/mysql.yaml'
                            sh 'kubectl apply -f k8s/app.yaml'
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