# Google Cloud Run R Shiny App Example

An example of how to deploy an R Shiny app on Google Cloud Run.

## Setup 

TODO 

## Workflow

```sh
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
DOCKER_REPO="shiny-run"
IMAGE_NAME="shiny-run"
IMAGE_TAG="latest"
IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG"
```

### enable apis 

```sh
gcloud services enable artifactregistry.googleapis.com
```

###  create repository

```sh
gcloud artifacts repositories create $DOCKER_REPO --repository-format=docker --location=$REGION --description="Docker repository for Shiny on Cloud Run demo"

gcloud artifacts repositories describe $DOCKER_REPO --location=$REGION
```

### configure auth

```sh
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
```

### build container iamge 

```sh
cd build && gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h
```

### Deploy to cloud run 

https://cloud.google.com/sdk/gcloud/reference/run/deploy

```sh
gcloud run deploy shiny --image $IMAGE_URI --region=$REGION --platform="managed" --max-instances=1 --port="5000" --no-allow-unauthenticated
```


## References


* [Deploying an R Shiny Dashboard on GCP Cloud Run | by Poorna Chathuranjana | Medium](https://medium.com/@hdpoorna/deploying-an-r-shiny-dashboard-on-gcp-cloud-run-c1c32a076783#6a58)
* [Deploying Shiny to Cloud Run • googleCloudRunner](https://code.markedmondson.me/googleCloudRunner/articles/usecase-shiny-cloudrun.html)
* [randy3k/shiny-cloudrun-demo: Running Shiny app on Google Cloud Run](https://github.com/randy3k/shiny-cloudrun-demo/tree/master)


## TODO 

* [ ] trim down dockerfile
