#!/bin/bash

IMAGE="health-app"
PROD_CONTAINER="health-container"
NGINX_CONF="/etc/nginx/sites-available/default"

echo "===== SMART PROMOTION START ====="

ACTIVE_PORT=$(grep -oP 'proxy_pass http://localhost:\K[0-9]+' $NGINX_CONF)
echo "Active port = $ACTIVE_PORT"

if [ "$ACTIVE_PORT" = "3001" ]; then
    NEW_PORT=3002
else
    NEW_PORT=3001
fi

echo "Deploying new slot on port $NEW_PORT"

TEMP_CONTAINER="health-slot-$NEW_PORT"

# find latest image
LATEST_IMAGE=$(docker images $IMAGE --format "{{.Tag}}" | sort -nr | head -1)

echo "Latest image tag = $LATEST_IMAGE"

docker rm -f $TEMP_CONTAINER >/dev/null 2>&1 || true

docker run -d \
--restart unless-stopped \
-p $NEW_PORT:3000 \
--name $TEMP_CONTAINER \
$IMAGE:$LATEST_IMAGE

echo "Waiting container startup..."

for i in {1..15}
do
    if curl -fs http://localhost:$NEW_PORT/health >/dev/null
    then
        echo "Health OK on $NEW_PORT"
        break
    fi
    sleep 2
done

if ! curl -fs http://localhost:$NEW_PORT/health >/dev/null
then
    echo "New slot failed health check"
    docker rm -f $TEMP_CONTAINER
    exit 1
fi

echo "Switching nginx → $NEW_PORT"

sudo sed -i "s|proxy_pass http://localhost:[0-9]*|proxy_pass http://localhost:$NEW_PORT|g" $NGINX_CONF

sudo nginx -t || exit 1
sudo systemctl reload nginx

echo "Removing old production container"
docker rm -f $PROD_CONTAINER >/dev/null 2>&1 || true

echo "Promoting new container"
docker rename $TEMP_CONTAINER $PROD_CONTAINER

echo "===== DEPLOYMENT SUCCESS ====="
docker ps