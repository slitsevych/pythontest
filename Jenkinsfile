pipeline {
  environment {
    registry = "slitsevych/pythontest"
    registryCredential = 'dockerhub'
    dockerImage = ''
  }
  agent any
  stages {
    stage('Test python') {
      steps {
          sh 'python3 --version'
      }
    }
    stage('Cloning Git') {
      steps {
        git 'git@github.com:slitsevych/pythontest.git'
      }
    }
    stage('Installing pip reqs and testing') {
      steps {
          sh 'pip3 install -r requirements.txt'
          sh 'python3 -m pytest -v'
          sh 'python3 -m unittest -v'
        }
    }
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build registry + ":$BUILD_NUMBER"
        }
      }
    }
    stage('Deploy Image') {
      steps {
        script {
          docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
    stage('Running docker') {
        steps {
            sh "docker run -d -p 5000:5000 --rm --name pythontest $registry:$BUILD_NUMBER"
        }
    }
    stage('Checking docker ps') {
        steps {
            sh "docker ps | grep $registry:$BUILD_NUMBER"
        }
    }
    stage('Checking container') {
        steps {
            sh "curl -I http://172.17.0.1:5000"
        }
    }
    stage('Stopping container') {
        steps {
            sh '''#!/bin/bash
                 if [[ $(curl -I http://172.17.0.1:5000|grep "200 OK"|wc -l) = 1 ]]; then echo "Ok" && docker stop pythontest; fi
         '''
        }
    }
    stage('Remove unused docker image') {
      steps {
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }
  }
  post {
        always {
            echo 'Sending email...'

            emailext body: "${currentBuild.currentResult}: Job  '${env.JOB_NAME}' build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']],
                subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}"
              }
      }
}
