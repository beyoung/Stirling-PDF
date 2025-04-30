
#!/bin/bash
# Build the jar
./gradlew build

# Build the docker image
sudo docker build -t beyouth/stirling-pdf:latest -f Dockerfile.ultra-lite .

# Stop and remove the existing container
sudo docker stop stirling-pdf && sudo docker rm stirling-pdf

# Run the docker image
sudo docker run -d \
  --name stirling-pdf \
  --restart unless-stopped \
  -p 20001:8080 \
  -v "./volumes/trainingData:/usr/share/tessdata" \
  -v "./volumes/extraConfigs:/configs" \
  -v "./volumes/customFiles:/customFiles/" \
  -v "./volumes/logs:/logs/" \
  -v "./volumes/pipeline:/pipeline/" \
  -e DOCKER_ENABLE_SECURITY=false \
  -e LANGS=en_GB \
  -e "UI_APPNAME=PDF tools" \
  -e "UI_HOMEDESCRIPTION=Your locally hosted one-stop-shop for all your PDF needs." \
  -e "UI_APPNAVBARNAME=PDF tools" \
  beyouth/stirling-pdf:latest