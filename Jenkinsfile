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
        AWS_CREDENTIAL_NAME = 'AWSCredentials'
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
                withAWS(region:"${REGION}",credentials:"${AWS_CREDENTIAL_NAME}"){
                 s3Upload(file:"deploy.zip",bucket:"team5-codedeploy-bucket")
                }
                sh 'rm -rf ./deploy.zip'
              }
            }
        }
        stage('Codedeploy Workload') {
              steps {
               echo "create Codedeploy group"   
                sh '''
                    aws deploy create-deployment-group \
                    --application-name 5team-code-deploy \
                    --auto-scaling-groups team5-asg \
                    --deployment-group-name 5team-code-deploy-${BUILD_NUMBER} \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --service-role-arn arn:arn:aws:iam::491085389788:role/team5-CodeDeployServiceRole
                    '''
                echo "Codedeploy Workload"   
                sh '''
                    aws deploy create-deployment --application-name team5-code-deploy \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --deployment-group-name team5-code-deploy-${BUILD_NUMBER} \
                    --s3-location bucket=team5-codedeploy-bucket,bundleType=zip,key=deploy.zip
                    '''
                    sleep(10) // sleep 10s
  }
}
   
    }   
     }
