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
                sh 'mvn -Dmaven.test.failure.ignore=true package'
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
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        
        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'
                sh "docker push yangjunseok/spring-petclinic:$BUILD_NUMBER"
                sh "docker push yangjunseok/spring-petclinic:latest"
            }
        }

        stage('Prepare Deployment File') {
            steps {
                sh 'sudo cp /home/ubuntu/spring-petclinic-deployment.yaml $WORKSPACE/'
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes Cluster'
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    export PATH=$PATH:/usr/bin
                    kubectl apply -f $WORKSPACE/spring-petclinic-deployment.yaml -n spring-petclinic
                    '''
                }
            }
        }
    }
}

