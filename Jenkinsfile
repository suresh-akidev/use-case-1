pipeline{
    agent any
    stages {
        stage('Pull Docker Image 01') {
            steps {
                script {
                  sh 'docker run -d nginx'
                }
            }
        }
    }
}