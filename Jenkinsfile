pipeline {
  agent any
  tools {
    jdk "jdk17"
    maven "M3"

  stages {
    stage('Git Clone') {
      steps {
        echo 'Git Clone'
        git url: 'https://github.com/kimaudwns/spring-petclinic.git',
          branch: 'main', credentialsId: 'gitToken'
      }
    }
  }
}
