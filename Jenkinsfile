pipeline {
    agent any

    environment {
        SERVER = "ubuntu@3.110.184.99"
        APP_DIR = "/home/ubuntu/health-app"
        CONTAINER = "health-container"
        IMAGE = "health-app"
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

                docker build -t $IMAGE:new .

                # tag current running image as old (if exists)
                docker image inspect $IMAGE:new >/dev/null 2>&1

                docker stop $CONTAINER || true
                docker rm $CONTAINER || true

                docker run -d -p 3000:3000 --name $CONTAINER $IMAGE:new
                '
                """
            }
        }

        stage('Health Check') {
            steps {
                sh """
                sleep 15
                curl -f http://3.110.184.99:3000/health
                """
            }
        }

    }

    post {

        success {
            sh """
            ssh $SERVER '
            docker tag $IMAGE:new $IMAGE:old
            '
            """
        }

        failure {
            sh """
            ssh $SERVER '
            docker stop $CONTAINER || true
            docker rm $CONTAINER || true
            docker run -d -p 3000:3000 --name $CONTAINER $IMAGE:old || true
            '
            """
        }

    }
}