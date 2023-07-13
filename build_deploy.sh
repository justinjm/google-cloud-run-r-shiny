#!/bin/bash

source args

cp ./.Renviron ./build/app/.Renviron

gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h ./build

gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_URI \
  --region=$REGION \
  --platform="managed" \
  --port="5000" \
  --no-allow-unauthenticated \
  --session-affinity \
  --service-account=$SVC_ACCOUNT_EMAIL

gcloud beta run services proxy $SERVICE_NAME --project=$PROJECT_ID --region=$REGION
