pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'M3'
    }
    
    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockerCredentials')
        KUBE_CONFIG = credentials('kubeconfig')
    }

    stages {
        stage('Git Clone') {
            steps {
                echo 'Git Clone'
                git url: 'https://github.com/junseok0713/spring-petclinic.git',
                branch: 'main', credentialsId: 'gitToken'
            }
            post {
                success {
                    echo 'Success git clone step'
                }
                failure {
                    echo 'Fail git clone step'
                }
            }
        }

        stage('Maven Build') {
            steps {
                echo 'Maven Build'
                sh 'mvn -Dmaven.repo.local=$HOME/.m2/repository -Dmaven.test.failure.ignore=true package'
            }
            post {
                success {
                    junit '**/target/surefire-reports/TEST-*.xml'
                }
            }
        }

        stage('Docker Image Build') {
            steps {
                echo 'Docker Image build'
                dir("${env.WORKSPACE}") {
                    sh """
                    docker build -t yangjunseok/spring-petclinic:$BUILD_NUMBER .
                    docker tag yangjunseok/spring-petclinic:$BUILD_NUMBER yangjunseok/spring-petclinic:latest
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    // Docker Hub에 로그인하고 상태를 확인
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin && docker info'
                }
            }
        }

        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'
                // Docker 이미지 푸시
                sh "docker push yangjunseok/spring-petclinic:$BUILD_NUMBER"
                sh "docker push yangjunseok/spring-petclinic:latest"
            }
        }

        stage('Cleaning up') { 
            steps { 
                echo 'Cleaning up unused Docker images on Jenkins server'
                sh """
                docker rmi yangjunseok/spring-petclinic:$BUILD_NUMBER || true
                docker rmi yangjunseok/spring-petclinic:latest || true
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes Cluster'
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    export KUBECONFIG=$KUBECONFIG
                    kubectl config view
                    kubectl get nodes --insecure-skip-tls-verify
                    kubectl set image deployment/spring-petclinic spring-petclinic=yangjunseok/spring-petclinic:$BUILD_NUMBER -n spring-petclinic --insecure-skip-tls-verify --record
                    '''
                }
            }
        }
    }
}
