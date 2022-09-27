pipeline{
    agent any
    stages {
        stage('Pull Docker Image 02') {
            steps {
                script {
                  sh 'docker run -d nginx'
                }
            }
        }
    }
}