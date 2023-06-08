# Google Cloud Run R Shiny App Example

An example of how to deploy an R Shiny app on Google Cloud Run.

## Setup

TODO

## Workflow


### .Renviron 

Create an `.Renviron` file in the root of this project directory

```txt
# .Renviron
PROJECT_ID="<your-project-id>"
REGION="us-central1"
DATASET_ID="z_test"
BILLING_PROJECT_ID=PROJECT_ID
```

then copy it to the `build/app/` directory before proceeding (and deploying to cloud run)

```sh
cp ./.Renviron ./build/app/.Renviron
```

### Set constants 

As global environment variables:

```sh
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
DOCKER_REPO="shiny-run"
IMAGE_NAME="shiny-run"
IMAGE_TAG="latest"
IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG"
SERVICE_NAME="shiny"
```



### enable apis

```sh
gcloud services enable artifactregistry.googleapis.com
```

### create docker repository

```sh
gcloud artifacts repositories create $DOCKER_REPO \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repository for Shiny on Cloud Run demo"
```

```sh
gcloud artifacts repositories describe $DOCKER_REPO --location=$REGION
```

### configure auth

```sh
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
```

### build container iamge

``` sh
gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h ./build
```

### Create Service account and attach to cloud run

TODO 

<https://cloud.google.com/run/docs/securing/service-identity#gcloud>
<https://cloud.google.com/iam/docs/service-accounts-create#iam-service-accounts-create-gcloud>


```sh
# gcloud iam service-accounts create SA_NAME \
#     --description="DESCRIPTION" \
#     --display-name="DISPLAY_NAME"

## give default compute engine service account access to bucket
# gcloud projects describe ${PROJECT_ID} > project-info.txt
# PROJECT_NUM=$(cat project-info.txt | sed -nre 's:.*projectNumber\: (.*):\1:p')
# SVC_ACCOUNT="${PROJECT_NUM//\'/}-compute@developer.gserviceaccount.com"
# gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:$SVC_ACCOUNT --role roles/storage.objectAdmin
```

save as global variable for use in next step 

```sh
# export SVC_ACCOUNT=`XXXXXXXXXXX | jq -r '.cloudResource.serviceAccountId'`
# echo $SVC_ACCOUNT 
```

### Deploy to cloud run

<https://cloud.google.com/sdk/gcloud/reference/run/deploy>

```sh
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_URI \
  --region=$REGION \
  --platform="managed" \
  --max-instances=1 \
  --port="5000" \
  --no-allow-unauthenticated
  # \ -- service-account=$SVC_ACCOUNT 
```

### test with local proxy

Since we are disallowing all unauthenticated users, need to access via a proxy

```sh
gcloud beta run services proxy $SERVICE_NAME --project=$PROJECT_ID --region=$REGION
```

<https://cloud.google.com/run/docs/authenticating/developers#testing>

#### Run Shiny App from Cloud Shell for debugging

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
```

then view the logs:

```sh
cd /var/log/shiny-server/
```

then cleanup

```sh
docker stop <container id>
docker rmi $IMAGE_URI
```

### Cleanup

Delete (or only stop) cloud run service

```sh
gcloud run services delete $SERVICE_NAME --region=$REGION
# gcloud run services stop $SERVICE_NAME --region=$REGION # stop service only
```

Delete artifcat repository:

```sh 
# gcloud artifacts repositories delete $DOCKER_REPO
```

## References

* [Deploying Shiny to Cloud Run • googleCloudRunner](https://code.markedmondson.me/googleCloudRunner/articles/usecase-shiny-cloudrun.html)
  * [randy3k/shiny-cloudrun-demo: Running Shiny app on Google Cloud Run](https://github.com/randy3k/shiny-cloudrun-demo/tree/master)
* [Online payments for data science apps (DSaaS) using R, Shiny, Firebase, Paddle and Google Cloud Functions · Mark Edmondson](https://code.markedmondson.me/datascience-aas/)
* [Deploying an R Shiny Dashboard on GCP Cloud Run \| by Poorna Chathuranjana \| Medium](https://medium.com/@hdpoorna/deploying-an-r-shiny-dashboard-on-gcp-cloud-run-c1c32a076783#6a58)

**Google Cloud Blog Post**

* [Calculating physical climate risk for sustainable finance \| Google Cloud Blog](https://cloud.google.com/blog/topics/sustainability/calculating-physical-climate-risk-for-sustainable-finance)
  * [rsmsoftware / portfolio-climate-risk-analytics-design-pattern --- Bitbucket](https://bitbucket.org/rsmsoftware/portfolio-climate-risk-analytics-design-pattern/src/master/)
