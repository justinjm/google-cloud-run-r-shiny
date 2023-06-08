#!/bin/bash

source args

gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h ./build

gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_URI \
  --region=$REGION \
  --platform="managed" \
  --max-instances=1 \
  --port="5000" \
  --no-allow-unauthenticated

gcloud beta run services proxy $SERVICE_NAME --project=$PROJECT_ID --region=$REGION

## gcloud run services delete shiny --region=us-central1 ## 