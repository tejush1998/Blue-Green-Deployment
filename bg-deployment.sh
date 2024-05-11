#!/bin/bash

# Configuration
BLUE_DIR="/blue"
GREEN_DIR="/green"
GREEN_PORT="3001" # Port on which Green runs
BLUE_PORT="3000" # Port on which Blue runs
NGINX_CONFIG="/opt/homebrew/etc/nginx/nginx.conf"
# GITHUB_REPO="https://github.com/your-username/your-repo.git"

# Determine which environment is currently running (Blue or Green)
CURRENT_PORT=$(grep 'proxy_pass http://localhost:' $NGINX_CONFIG | sed 's/.*://;s/[^0-9].*//')
# Determine the old PM2 process name
OLD_NAME=""
TARGET_DIR=""

if [ "$CURRENT_PORT" == "$BLUE_PORT" ]; then
    TARGET_DIR=$GREEN_DIR
    TARGET_PORT=$GREEN_PORT
    OLD_NAME=$(basename $BLUE_DIR)
else
    TARGET_DIR=$BLUE_DIR
    TARGET_PORT=$BLUE_PORT
    OLD_NAME=$(basename $GREEN_DIR)
fi

echo $OLD_NAME
echo $TARGET_DIR
echo $TARGET_PORT
echo $CURRENT_PORT
# Step 1: Pull from GitHub into target environment
# echo "Pulling latest code into target environment ($TARGET_DIR)..."
cd $TARGET_DIR
# git pull $GITHUB_REPO

# # Step 2: Yarn Build for target version
# echo "Building target environment..."
# yarn install
# yarn build

# Start/Restart the target environment using PM2
TARGET_NAME=$(basename $TARGET_DIR)
# pm2 stop $TARGET_NAME
# pm2 delete $TARGET_NAME
pm2 start $TARGET_NAME/index.js --name "$TARGET_NAME" -- start -p $TARGET_PORT || pm2 restart $TARGET_NAME



# # Allow a few seconds for the server to start
sleep 5

# # Step 3: Check if target version index page returns 200
echo "Checking target environment health..."
STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:$TARGET_PORT)

if [ "$STATUS_CODE" -ne 200 ]; then
    echo "Target environment health check failed with status code: $STATUS_CODE"
    exit 1
fi

# # Step 4: Switch Nginx to target environment
echo "Switching Nginx to target environment..."
sed -i '' "s/proxy_pass http:\/\/localhost:[0-9]*;/proxy_pass http:\/\/localhost:$TARGET_PORT;/" $NGINX_CONFIG
sudo nginx -s reload

echo "Stopping old environment ($OLD_NAME)..."
pm2 stop $OLD_NAME
pm2 delete $OLD_NAME

pm2 save

echo "Deployment complete. Target environment ($TARGET_NAME) is now live!"
