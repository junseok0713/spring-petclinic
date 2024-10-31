pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        maven 'M3'
    }
    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockerCredentials')  // Docker Hub 자격 증명 ID
        REGION = "ap-northeast-2"  // AWS 리전
        AWS_CREDENTIAL_NAME = 'AWSCredentials'  // AWS 자격 증명 ID
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
                    docker build -t junseok0713/spring-petclinic:$BUILD_NUMBER .
                    docker tag junseok0713/spring-petclinic:$BUILD_NUMBER kimaudwns/spring-petclinic:latest
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
                sh "docker push junseok0713/spring-petclinic:latest"  // Docker 이미지 푸시
            }
        }
        
        stage('Cleaning up') { 
            steps { 
                // Jenkins 서버의 사용하지 않는 Docker 이미지 제거
                echo 'Cleaning up unused Docker images on Jenkins server'
                sh """
                docker rmi junseok0713/spring-petclinic:$BUILD_NUMBER
                docker rmi junseok0713/spring-petclinic:latest
                """
            }
        }
        
        stage('Upload S3') {
            steps {
                echo "Upload to S3"
                dir("${env.WORKSPACE}") {
                    sh 'zip -r deploy.zip ./deploy appspec.yml'
                    
                    // AWS 자격 증명과 함께 S3에 파일 업로드
                    withAWS(region: "${REGION}", credentials: "${AWS_CREDENTIAL_NAME}") {
                        s3Upload(file: "deploy.zip", bucket: "team5-codedeploy-bucket")
                    }
                    
                    sh 'rm -rf deploy.zip'  // 임시 zip 파일 삭제
                }
            }
        }

        stage('Codedeploy Workload') {
            steps {
                echo "create Codedeploy group"
                
                // AWS 자격 증명 설정 추가 (withAWS 블록 사용)
                withAWS(region: "${REGION}", credentials: "${AWS_CREDENTIAL_NAME}") {
                    sh '''
                    aws deploy create-deployment-group \
                    --application-name team5-codedeploy \
                    --auto-scaling-groups team5-asg \
                    --deployment-group-name team5-codedeploy-${BUILD_NUMBER} \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --service-role-arn arn:aws:iam::491085389788:role/team5-CodeDeployServiceRole
                       '''
                    echo "Codedeploy Workload"
                    sh '''
                    aws deploy create-deployment \
                    --application-name team5-codedeploy \
                    --deployment-config-name CodeDeployDefault.OneAtATime \
                    --deployment-group-name team5-codedeploy-${BUILD_NUMBER} \
                    --s3-location bucket=team5-codedeploy-bucket,bundleType=zip,key=deploy.zip
                    '''
                }
                
                sleep(10)  // 10초 대기
            }
        }
    }
}
