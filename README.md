# Google Cloud Run R Shiny App Example

An example of how to deploy an R Shiny app on Google Cloud Run.

![](img/app-screenshot.png)

## Getting started

### Cloud Shell

Work from Cloud Shell by clicking the button below:

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fjustinjm%2Fgoogle-cloud-run-r-shiny&cloudshell_git_branch=main)

### Other environment

Or you can clone this repository to your development environment of choice

```sh
git clone https://github.com/justinjm/google-cloud-run-r-shiny
```

## Setup local evironment

### Authentication (Cloud Shell)

run the following in Cloud Shell Terminal to trigger authentication

```sh
gcloud config list
```

### Authentication (non-cloud shell)

* Install `gcloud` CLI
* Set ADC on your local machine so you can test the app locally <https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login>

```sh
gcloud auth application-default login
```

### Set constants

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

### .Renviron

Create an `.Renviron` file in the root of this project directory and then copy it to the `build/app/` directory by running the following:

```sh
cat << EOF > ./.Renviron
# .Renviron
PROJECT_ID=$PROJECT_ID
REGION=$REGION
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
gcloud services enable \
  bigquery.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  run.googleapis.com
```

## Build container image

### create Artifact Registry (docker repository)

Create an Artifact Registry (AR) repository (repo) to serve as our docker repository,

Running the code below will check if the repo exists first and create only if it does not exist.

```sh
## Create artifact registry only if it does not already exist
# Check if the repository already exists
if gcloud artifacts repositories describe $DOCKER_REPO --location=$REGION &> /dev/null; then
  echo "Repository $DOCKER_REPO already exists:"
  gcloud artifacts repositories describe $DOCKER_REPO --location=$REGION
else
  # Create the repository if it doesn't exist
  echo "Respository does not exist. Creating...."
  gcloud artifacts repositories create $DOCKER_REPO \
    --repository-format=docker \
    --location=$REGION \
    --description="Docker repository for Shiny on Cloud Run demo"
  echo "Repository created."
  gcloud artifacts repositories describe $DOCKER_REPO --location=$REGION
fi 
```

### configure auth

```sh
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
```

### build container image

```sh
gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h ./build
```

### Create Service account and grant permissions

To follow Google Cloud recommended best practices for service accounts.

* <https://cloud.google.com/run/docs/deploying#permissions_required_to_deploy>
* <https://cloud.google.com/run/docs/reference/iam/roles#additional-configuration>
* <https://cloud.google.com/run/docs/securing/service-identity#gcloud>
* <https://cloud.google.com/iam/docs/service-accounts-create#iam-service-accounts-create-gcloud>
* <https://cloud.google.com/iam/docs/understanding-roles>

```sh
gcloud iam service-accounts create $SVC_ACCOUNT_NAME \
    --description="For deploying R Shiny apps on Cloud Run" \
    --display-name="R Shiny Cloud Run service account"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SVC_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/aiplatform.user"
```

save as global variable for use in next step

```sh
export SVC_ACCOUNT_EMAIL=$SVC_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com
echo $SVC_ACCOUNT_EMAIL
```

## Deploy to cloud run (public)

Deploy app from container image we built in previous step to be publicly accessible

<https://cloud.google.com/sdk/gcloud/reference/run/deploy>
<https://cloud.google.com/run/docs/configuring/session-affinity>

```sh
source args 

gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_URI \
  --region=$REGION \
  --platform="managed" \
  --port="5000" \
  --allow-unauthenticated \
  --session-affinity \
  --service-account=$SVC_ACCOUNT_EMAIL \
  --min-instances=1 \
  --max-instances=10
```

### Run Shiny App from Cloud Shell for debugging

See [docs/debugging.md](docs/debugging.md) for instructions

## Private testing

### Allow only authenticated users to access (Cloud IAM)

First, deploy allowing only authenticated users:

```sh
source args 

gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_URI \
  --region=$REGION \
  --platform="managed" \
  --port="5000" \
  --no-allow-unauthenticated \
  --session-affinity \
  --service-account=$SVC_ACCOUNT_EMAIL \
  --min-instances=1 \
  --max-instances=10
```

### test with local proxy (if `--no-allow-unauthenticated`)

Then access via a proxy

```sh
gcloud beta run services proxy $SERVICE_NAME --project=$PROJECT_ID --region=$REGION
```

<https://cloud.google.com/run/docs/authenticating/developers#testing>

## Cleanup

Delete all created services

```sh
## gcloud run services delete $SERVICE_NAME --region=$REGION
## gcloud artifacts repositories delete $DOCKER_REPO ## 
## gcloud iam service-accounts delete $SVC_ACCOUNT_EMAIL ## 
```
<https://cloud.google.com/iam/docs/service-accounts-delete-undelete>

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
