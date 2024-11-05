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
        
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes Cluster'
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    export PATH=$PATH:/usr/bin
                    kubectl apply -f spring-petclinic-deployment.yaml -n spring-petclinic
                    '''
                }
            }
        }
    }
}

