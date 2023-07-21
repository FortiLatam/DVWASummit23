#!/bin/bash

kubectl delete -f deployment.yml
terraform -chdir=tf-fwbcloud/ init
terraform -chdir=tf-fwbcloud/ destroy --auto-approve
terraform -chdir=tf-fgtvm/ init
terraform -chdir=tf-fgtvm/ destroy --auto-approve
