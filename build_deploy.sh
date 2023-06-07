#!/bin/bash

PROJECT_ID=$(gcloud config get-value project)
GCLOUD_USER=$(gcloud config get-value core/account)
REGION="us-central1"
DOCKER_REPO="shiny-run"
IMAGE_NAME="shiny-run"
IMAGE_TAG="latest"
IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG"
SERVICE_NAME="shiny"

gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h ./build

gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_URI \
  --region=$REGION \
  --platform="managed" \
  --max-instances=1 \
  --port="5000" \
  --no-allow-unauthenticated

  gcloud beta run services proxy $SERVICE_NAME --project=$PROJECT_ID --region=$REGION

  ## gcloud run services delete $SERVICE_NAME --region=$REGION ## 