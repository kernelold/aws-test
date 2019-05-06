#!/bin/bash
docker build -t quoteapp:latest .
docker tag quoteapp:latest 577043135686.dkr.ecr.us-west-1.amazonaws.com/quoteapp:latest
$(aws ecr get-login --no-include-email --region us-west-1)
docker push 577043135686.dkr.ecr.us-west-1.amazonaws.com/quoteapp:latest
