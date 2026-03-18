pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'echo "Building project..."'
                // Add your build command here
                // sh './gradlew build' or sh 'mvn clean package'
            }
        }
        
        stage('Test') {
            steps {
                sh 'echo "Running tests..."'
                // sh './gradlew test' or sh 'mvn test'
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'echo "Deploying application..."'
                // Add your deployment commands here
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline finished'
        }
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed!'
        }
    }
}