#!/bin/bash

source args

gcloud builds submit --region=$REGION --tag=$IMAGE_URI --timeout=1h ./build

