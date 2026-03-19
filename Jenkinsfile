pipeline {
    agent any

    environment {
        SERVER = "ubuntu@43.205.145.11    "
        APP_DIR = "/home/ubuntu/health-app"
        CONTAINER = "health-container"
        TEMP_CONTAINER = "health-container-temp"
        IMAGE = "health-app"
        TEMP_PORT = "3001"
        NGINX_CONF="/etc/nginx/sites-available/default"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Satyamkan10/optimize-ci-cd.git'
            }
        }

        stage('Deploy on Server') {
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no $SERVER '

                if [ ! -d "$APP_DIR" ]; then
                    git clone https://github.com/Satyamkan10/optimize-ci-cd.git $APP_DIR
                else
                    cd $APP_DIR && git pull origin main
                fi

                cd $APP_DIR

                docker build -t $IMAGE:$BUILD_NUMBER .

                docker run -d -p 3001:3000 --name $TEMP_CONTAINER $IMAGE:$BUILD_NUMBER || true
                '
                """
            }
        }

        stage('Health Check') {
            steps {
                sh """
                sleep 15
                curl -f http://3.109.143.141:3001/health
                """
            }
        }

    }

    post {

        success {
            sh """
            ssh $SERVER 'bash /home/ubuntu/promote.sh'
"""
        }
        failure {
            sh """
            ssh $SERVER "
            docker rm -f $TEMP_CONTAINER || true
            "
            """
        }

    }
}
