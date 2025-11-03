 sudo docker stop azure-region-viewer
 sudo docker rm azure-region-viewer
 sudo docker run -d --name azure-region-viewer --restart unless-stopped -p 80:3000 madedroo/azure-region-viewer:latest

   