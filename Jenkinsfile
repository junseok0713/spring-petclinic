pipeline {
    agent any

    // Jenkins에서 사용할 JDK 및 Maven 버전 설정
    tools {
        jdk 'jdk17'
        maven 'M3'
    }
    
    // 환경 변수 설정: Docker Hub와 Kubernetes 접근에 필요한 자격 증명을 Jenkins 자격 증명에서 가져옵니다.
    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockerCredentials') // Docker Hub 로그인 정보
        KUBE_CONFIG = credentials('kubeconfig') // Kubernetes kubeconfig 파일
    }

    stages {
        stage('Git Clone') {
            // Git에서 프로젝트 코드 클론 단계
            steps {
                echo 'Git Clone'
                git url: 'https://github.com/junseok0713/spring-petclinic.git', // Git 저장소 URL
                branch: 'main', credentialsId: 'gitToken' // main 브랜치 및 자격 증명 ID 설정
            }
            post {
                success {
                    echo 'Success git clone step' // Git 클론 성공 시 메시지 출력
                }
                failure {
                    echo 'Fail git clone step' // Git 클론 실패 시 메시지 출력
                }
            }
        }

        stage('Maven Build') {
            // Maven을 사용하여 빌드
            steps {
                echo 'Maven Build'
                sh 'mvn -Dmaven.repo.local=$HOME/.m2/repository -Dmaven.test.failure.ignore=true package' // Maven 빌드 명령어
            }
            post {
                success {
                    junit '**/target/surefire-reports/TEST-*.xml' // 빌드 성공 시 테스트 결과 보고
                }
            }
        }

        stage('Docker Image Build') {
            // Docker 이미지를 빌드하고 태그 지정
            steps {
                echo 'Docker Image build'
                dir("${env.WORKSPACE}") {
                    sh """
                    docker build -t yangjunseok/spring-petclinic:$BUILD_NUMBER . // Docker 이미지 생성
                    docker tag yangjunseok/spring-petclinic:$BUILD_NUMBER yangjunseok/spring-petclinic:latest // 최신 버전으로 태그 지정
                    """
                }
            }
        }

        stage('Docker Login') {
            // Docker Hub에 로그인
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Docker Image Push') {
            // 생성된 이미지를 Docker Hub에 푸시
            steps {
                echo 'Docker Image Push'
                sh "docker push yangjunseok/spring-petclinic:$BUILD_NUMBER" // 빌드 넘버 버전 푸시
                sh "docker push yangjunseok/spring-petclinic:latest" // 최신 버전 푸시
            }
        }

        stage('Cleaning up') { 
            // Jenkins 서버에서 사용되지 않는 Docker 이미지 제거
            steps { 
                echo 'Cleaning up unused Docker images on Jenkins server'
                sh """
                docker rmi yangjunseok/spring-petclinic:$BUILD_NUMBER || true
                docker rmi yangjunseok/spring-petclinic:latest || true
                """
            }
        }

        stage('Deploy to Kubernetes') {
            // Kubernetes에 애플리케이션 배포
            steps {
                echo 'Deploying to Kubernetes Cluster'
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    export PATH=$PATH:/usr/bin // 경로에 /usr/bin 추가
                    export KUBECONFIG=$KUBECONFIG // kubeconfig 설정 파일 위치 지정
                    kubectl set image deployment/spring-petclinic spring-petclinic=yangjunseok/spring-petclinic:$BUILD_NUMBER -n spring-petclinic --insecure-skip-tls-verify --record
                    // Kubernetes 배포 이미지 업데이트 및 인증서 검증 생략
                    '''
                }
            }
        }
    }
}
