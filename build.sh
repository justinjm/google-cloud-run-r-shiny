#!/bin/bash

source args

cp ./.Renviron ./build/app/.Renviron

gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h ./build
