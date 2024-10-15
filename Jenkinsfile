pipeline {
    agent any
    
    tools {
        jdk 'JDK17'
        maven 'M3'
    }
    environment { 
        // jenkins에 등록해 놓은 docker hub credentials 이름
        DOCKERHUB_CREDENTIALS = credentials('DockerCredentials') 
    }

    stages {
        stage('Git Clone') {
            steps {
                echo 'Git Clone'
                git url: 'https://github.com/sjh4616/spring-petclinic.git',
                branch: 'efficient-webjars', credentialsId: 'GitHub-Token'
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
                    docker build -t kimaudwns/spring-petclinic:$BUILD_NUMBER .
                    docker tag kimaudwns/spring-petclinic:$BUILD_NUMBER kimaudwns/spring-petclinic:latest
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                // docker hub 로그인
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('Docker Image Push') {
            steps {
                echo 'Docker Image Push'  
                sh "docker push kimaudwns/spring-petclinic:latest"  // docker push
            }
        }
        stage('Cleaning up') { 
		        steps { 
              // docker image 제거
              echo 'Cleaning up unused Docker images on Jenkins server'
              sh """
              docker rmi kimaudwns/spring-petclinic:$BUILD_NUMBER
              docker rmi kimaudwns/spring-petclinic:latest
              """
            }
        }
        
        
    }
}
