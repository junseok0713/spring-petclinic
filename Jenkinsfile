pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        maven 'M3'
    }
    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockerCredentials')  // Docker Hub 자격 증명 ID
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
                // Docker Hub 로그인
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        
        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'  
                sh "docker push yangjunseok/spring-petclinic:$BUILD_NUMBER"  // $BUILD_NUMBER 태그 푸시
                sh "docker push yangjunseok/spring-petclinic:latest"  // latest 태그 푸시
            }
        }
        
        stage('Cleaning up') { 
            steps { 
                // Jenkins 서버의 사용하지 않는 Docker 이미지 제거
                echo 'Cleaning up unused Docker images on Jenkins server'
                sh """
                docker rmi yangjunseok/spring-petclinic:$BUILD_NUMBER
                docker rmi yangjunseok/spring-petclinic:latest
                """
            }
        }
    }
}
