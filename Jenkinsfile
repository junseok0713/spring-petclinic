pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        maven 'M3'
    }
    environment { 
        // jenkins에 등록해 놓은 docker hub credentials 이름
        DOCKERHUB_CREDENTIALS = credentials('dockerCredentials')
        REGION = "ap-northeast-2"
        AWS_CREDENTIALS = credentials('AWSCredentinals')
    }

    stages {
        stage('Git Clone') {
            steps {
                echo 'Git Clone'
                git url: 'https://github.com/kimaudwns/spring-petclinic.git',
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
        stage('Upload S3'){
            steps{
              echo "Upload to S3"
              dir("${env.WORKSPACE}"){
                sh 'zip -r deploy.zip ./deploy appspec.yml'
                withAWS(region:"${REGION}",credentials:"${AWS_CREDENTIALS}"){
                 s3upload(file:"deploy.zip",bucket:"user17-codedeploy-bucket")
                }
                sh 'rm -rf ./deploy.zip'
              }
            }
        }
        
    }
}
