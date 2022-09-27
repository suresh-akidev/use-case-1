pipeline{
    agent any
    stages {
        stage('Pull Docker Image 03') {
            steps {
                script {
                  sh 'docker run -d nginx'
                }
            }
        }
    }
}