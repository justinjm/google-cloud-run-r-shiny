# Debugging

Documentation to assist with debugging and development.

pull docker image from artifact repository

```sh
docker pull $IMAGE_URI
```

start container from image on proper port

```sh
docker run --rm -p 5000:5000 $IMAGE_URI
```

list running containers to get container id for next step

```sh
docker ps
```

replace container id and enter docker container

```sh
docker exec -it <container id>  bash
# export CONTAINER_ID=$(docker ps -q | head -n 1) # first running container
# export CONTAINER_ID=$(docker ps -q --filter ancestor=$IMAGE_URI) # filtered by name
```

Now open a new shell and  view the logs

```sh
cd /var/log/shiny-server/
```

then cleanup

```sh
docker stop <container id>
# docker stop $CONTAINER_ID
docker rmi $IMAGE_URI
```
