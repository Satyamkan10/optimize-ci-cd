pipeline {
    agent any

    environment {
        SERVER = "ubuntu@3.110.184.99"
        APP_DIR = "/home/ubuntu/health-app"
        CONTAINER = "health-container"
        TEMP_CONTAINER = "health-container-temp"
        IMAGE = "health-app"
        TEMP_PORT = "3001"
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
                curl -f http://3.110.184.99:3001/health
                """
            }
        }

    }

    post {

        success {
            sh """
            ssh $SERVER '
            docker stop $CONTAINER || true
            docker rm $CONTAINER || true

            echo "===== Switching Nginx Traffic ====="

        
            NGINX_CONF="/etc/nginx/sites-available/default"

            echo "Updating nginx upstream to port $TEMP_PORT..."

            sudo sed -i 's|proxy_pass http://localhost:[0-9]*|proxy_pass http://localhost:'"$TEMP_PORT"'|g' $NGINX_CONF

            echo "Testing nginx config..."
            sudo nginx -t

            echo "Reloading nginx..."
            sudo systemctl reload nginx

            echo "Traffic switched successfully"
            docker rename $TEMP_CONTAINER $CONTAINER
                       '
            """
        }

        failure {
            sh """
            ssh $SERVER '
            docker stop $TEMP_CONTAINER || true
            docker rm $TEMP_CONTAINER || true
            '
            """
        }

    }
}