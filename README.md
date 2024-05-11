# Blue-green-deployment

## Setup & Installation (MacOS)

```sh
brew install nginx
npm install -g pm2
```
### Overwrite nginx.conf file 

```
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://localhost:3000;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
```

### Start nginx

```sh
sudo nginx
pm2 start blue/index.js --name blue -p 3000
```

### Server will start at

```
http://locahost:80
```

Run deployment script to switch between blue and green apps without downtime on same port

```
chmod +x bg-deployment.sh
./bg-deployment.sh
```


