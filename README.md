# Google Cloud Run R Shiny App Example

An example of how to deploy an R Shiny app on Google Cloud Run.

## Getting started

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fjustinjm%2Fgoogle-cloud-run-r-shiny&cloudshell_git_branch=main)

Or you can clone this repso

```sh
git clone https://github.com/justinjm/google-cloud-run-r-shiny
```

### Setup Local evironment

#### Authentication

* Install `gcloud` CLI
* Set ADC on your local machine so you can test the app locally <https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login>

```sh
gcloud auth application-default login
```

#### Set constants

As global environment variables here for re-use throughout the rest of the steps

```sh
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
SVC_ACCOUNT_NAME="shiny-run"
DOCKER_REPO="shiny-run"
IMAGE_NAME="shiny-run"
IMAGE_TAG="latest"
IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG"
SERVICE_NAME="shiny"
```

#### .Renviron

Create an `.Renviron` file in the root of this project directory and then copy it to the `build/app/` directory by running the following:

```sh
cat << EOF > ./.Renviron
# .Renviron
PROJECT_ID=$PROJECT_ID
REGION=$REGION
DATASET_ID="z_test"
BILLING_PROJECT_ID=$PROJECT_ID
EOF

cp ./.Renviron ./build/app/.Renviron
```

While it's non-ideal we need the `.Renviron` file in 2 places:

1. the project root directory for development of the shiny app in RStudio, this is where the app looks
2. the `build/app` directory for deployment of the shiny app to Google Cloud Run

This can be avoided with a Terraform workflow and I plan to add it here, see [issue](https://github.com/justinjm/google-cloud-run-r-shiny/issues/1)) for status.

Please note that for now, you must ensure these 2 files are in sync to avoid any deployment issues.

## Setup Google Cloud

### enable apis

```sh
gcloud services enable artifactregistry.googleapis.com
```

## Build container image

### create Artifact Registry (docker repository)

Create an Artifact Registry (AR) repository (repo) to serve as our docker repository.

```sh
gcloud artifacts repositories create $DOCKER_REPO \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repository for Shiny on Cloud Run demo"
```

view newly created AR repo to sanity check

```sh
gcloud artifacts repositories describe $DOCKER_REPO --location=$REGION
```

### configure auth

```sh
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
```

### build container iamge

```sh
gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h ./build
```

### Create Service account and attach to cloud run

TODO

<https://cloud.google.com/run/docs/securing/service-identity#gcloud>
<https://cloud.google.com/iam/docs/service-accounts-create#iam-service-accounts-create-gcloud>

```sh
# gcloud iam service-accounts create $SVC_ACCOUNT_NAME \
#     --description="DESCRIPTION" \
#     --display-name="DISPLAY_NAME"
# 
## give SA acccoutn access to 
### Cloud Storage
### BQ 
### cloud run
### vertex
# gcloud projects describe ${PROJECT_ID} > project-info.txt
# PROJECT_NUM=$(cat project-info.txt | sed -nre 's:.*projectNumber\: (.*):\1:p')
# SVC_ACCOUNT="${}-compute@developer.gserviceaccount.com"
# gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:$SVC_ACCOUNT --role roles/XXXXXXXXXXXXXXXX
```

save as global variable for use in next step

```sh
# export SVC_ACCOUNT=`XXXXXXXXXXX | jq -r '.cloudResource.serviceAccountId'`
# echo $SVC_ACCOUNT 
```

## Deploy to cloud run

### Deploy app from image

Deploy app from container image we built in previous step

```sh
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_URI \
  --region=$REGION \
  --platform="managed" \
  --max-instances=1 \
  --port="5000" \
  --no-allow-unauthenticated 
```

<https://cloud.google.com/sdk/gcloud/reference/run/deploy>
<https://cloud.google.com/run/docs/configuring/session-affinity>

TODO - try with

* no max instances
* session affinity enabled
* dedicated service account


```sh
# gcloud run deploy $SERVICE_NAME \
#   --image $IMAGE_URI \
#   --region=$REGION \
#   --platform="managed" \
#   --port="5000" \
#   --no-allow-unauthenticated \
#   --session-affinity \
#   --service-account=$SVC_ACCOUNT
```


### test with local proxy

Since we are disallowing all unauthenticated users, need to access via a proxy

```sh
gcloud beta run services proxy $SERVICE_NAME --project=$PROJECT_ID --region=$REGION
```

<https://cloud.google.com/run/docs/authenticating/developers#testing>

#### Run Shiny App from Cloud Shell for debugging

See [docs/debugging.md](docs/debugging.md) for instructions

### Cleanup

Delete (or only stop) cloud run service

```sh
# gcloud run services stop $SERVICE_NAME --region=$REGION # stop service only
gcloud run services delete $SERVICE_NAME --region=$REGION
```

Delete AR repo:

```sh
# gcloud artifacts repositories delete $DOCKER_REPO
```

## Original Source

Source code forked from [tolgakurtuluss/shinychatgpt](https://github.com/tolgakurtuluss/shinychatgpt), thank you to [tolgakurtuluss](https://github.com/tolgakurtuluss) for open sourcing and sharing your project.

## References

* [Deploying Shiny to Cloud Run • googleCloudRunner](https://code.markedmondson.me/googleCloudRunner/articles/usecase-shiny-cloudrun.html)
  * [randy3k/shiny-cloudrun-demo: Running Shiny app on Google Cloud Run](https://github.com/randy3k/shiny-cloudrun-demo/tree/master)
* [Online payments for data science apps (DSaaS) using R, Shiny, Firebase, Paddle and Google Cloud Functions · Mark Edmondson](https://code.markedmondson.me/datascience-aas/)
* [Deploying an R Shiny Dashboard on GCP Cloud Run \| by Poorna Chathuranjana \| Medium](https://medium.com/@hdpoorna/deploying-an-r-shiny-dashboard-on-gcp-cloud-run-c1c32a076783#6a58)

### Official Google Cloud Blog Post

* [Calculating physical climate risk for sustainable finance \| Google Cloud Blog](https://cloud.google.com/blog/topics/sustainability/calculating-physical-climate-risk-for-sustainable-finance)
  * [rsmsoftware / portfolio-climate-risk-analytics-design-pattern --- Bitbucket](https://bitbucket.org/rsmsoftware/portfolio-climate-risk-analytics-design-pattern/src/master/)
