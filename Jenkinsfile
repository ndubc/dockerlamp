pipeline {
    agent any


    triggers {
         pollSCM('* * * * *')
     }

stages{
        stage('Build'){
            steps {
                sh '/bin/docker image build -t josephlamp .'
            }
            post {
                success {
                        sh 'docker rm -f LAMP || true'
                        sh 'docker run -d -p 80:80 --name LAMP josephlamp'
                }
            }
        }
     }
}
