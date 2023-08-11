pipeline {
    agent any
    environment {
        IMAGE_REPO_NAME="dvwapub"
        //REPLACE XXX WITH YOUR STUDENT NUMBER
        IMAGE_TAG= "std404"
        REPOSITORY_URI = "public.ecr.aws/f9n2h3p5/dvwapub"
        AWS_DEFAULT_REGION = "us-east-1"
        APP_NAME="dvwa"
        API_FWB_TOKEN = credentials('FWB_TOKEN')
        API_FGT_TOKEN = credentials('FGT_TOKEN')
        CNAME_APP = "dvwa.fortixperts.com"
        ZONE_ID = "Z038024434JSU4YEEE1I7"
        SDN_NAME = "EKSSDN"
        DYN_ADDR_NAME = "DVWA_PODS"
        FGT_IP = "34.204.90.236"
        FGT_PORT = "8443"
    }
   
    stages {
    
    stage('Logging into AWS ECR') {
            steps {
                script {
                sh """aws ecr-public get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${REPOSITORY_URI} """
                }
                 
            }
    } 
    
    stage('Clone repository') { 
            steps { 
                script{
                checkout scm
                }
            }
        }  
/*SAST*/    
    stage('SAST'){
            steps {
                 sh 'env | grep -E "JENKINS_HOME|BUILD_ID|GIT_BRANCH|GIT_COMMIT" > /tmp/env'
                 sh 'docker pull registry.fortidevsec.forticloud.com/fdevsec_sast:latest'
                 sh 'docker run --rm --env-file /tmp/env --mount type=bind,source=$PWD,target=/scan registry.fortidevsec.forticloud.com/fdevsec_sast:latest'
            }
    }
/*END SAST*/
    // Building Docker images
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}-${env.BUILD_NUMBER}"
        }
      }
    }
   
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh """docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG}-${env.BUILD_NUMBER} ${REPOSITORY_URI}:$IMAGE_TAG-${env.BUILD_NUMBER}"""
                sh """docker push ${REPOSITORY_URI}:${IMAGE_TAG}-${env.BUILD_NUMBER}"""
         }
        }
      }
/*ADD to FWB*/
    stage('Deploy'){
            steps {
                 sh 'sed -i "s/<TAG>/${IMAGE_TAG}-${BUILD_NUMBER}/" deployment.yml'
                 sh 'sed -i "s/<APP_NAME>/${APP_NAME}/" deployment.yml'
                 sh 'kubectl apply -f deployment.yml'
                 sh 'sleep 30'
            }
    } 

    stage('Add app to FortiWeb-Cloud'){
            steps {
                 script {
                    sh '''#!/bin/bash
                    EXTERNAL_IP=`kubectl get svc dvwa --output="jsonpath={.status.loadBalancer.ingress[0].hostname}"`
                    sed -i "s/<EXTERNAL_LBIP>/$EXTERNAL_IP/" tf-fwbcloud/tf-fwb.tf
                    sed -i "s/<DAST_URL>/$EXTERNAL_IP/" fdevsec.yaml''' 
                 }
                 sh 'echo "Waiting for load balancer be ready..." |sleep 15'
                 //sh 'sed -i "s/<EXTERNAL_LBIP>/${EXTERNAL_IP}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<API_FWB_TOKEN>/${API_FWB_TOKEN}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<APP_NAME>/${APP_NAME}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<CNAME_APP>/${CNAME_APP}/" tf-fwbcloud/tf-fwb.tf'                 
                 sh 'terraform -chdir=tf-fwbcloud/ init'
                 sh 'terraform -chdir=tf-fwbcloud/ apply --auto-approve'    
          
            }
    }

    stage('Change DNS record FWB'){
            steps {
                 script { 
                    sh 'sed -i "s/<CNAME_APP>/${CNAME_APP}/" r53app.json'
                    sh '''#!/bin/bash
                    CNAME_FWB=`terraform -chdir=tf-fwbcloud/ output -json | jq .cname.value -r |tr -d '"|]|['`
                    sed -i "s/<CNAME_FWB>/${CNAME_FWB}/" r53app.json '''
                    sh 'aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file://r53app.json --profile master'
                 }
            }
    }
/*END FWB*/
/* Deploy and Change DNS Record WITHOUT FWB

    stage('Deploy'){
            steps {
                 sh 'sed -i "s/<TAG>/${IMAGE_TAG}-${BUILD_NUMBER}/" deployment-public.yml'
                 sh 'sed -i "s/<APP_NAME>/${APP_NAME}/" deployment-public.yml'
                 sh 'kubectl apply -f deployment-public.yml'
                 sh 'sleep 30'
            }
    } 

    stage('Change DNS record'){
            steps {
                 script { 
                    sh 'sed -i "s/<CNAME_APP>/${CNAME_APP}/" r53app.json'
                    sh '''#!/bin/bash
                    CNAME_FWB=`kubectl get svc dvwa --output="jsonpath={.status.loadBalancer.ingress[0].hostname}"`
                    sed -i "s/<CNAME_FWB>/${CNAME_FWB}/" r53app.json '''
                    sh 'aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file://r53app.json --profile master'
                 }
            }
    }
 END Change DNS Record WITHOUT FWB*/
/*FGT*/
    stage('Add FortiGate settings'){
            steps {
                 script { 
                    sh 'sed -i "s/<API_FGT_TOKEN>/${API_FGT_TOKEN}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<SDN_NAME>/${SDN_NAME}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<APP_NAME>/${APP_NAME}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<DYN_ADDR_NAME>/${DYN_ADDR_NAME}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<FGT_IP>/${FGT_IP}/" tf-fgtvm/tf-fgt.tf'
                    sh 'sed -i "s/<FGT_PORT>/${FGT_PORT}/" tf-fgtvm/tf-fgt.tf'
                    sh 'terraform -chdir=tf-fgtvm/ init'
                    sh 'terraform -chdir=tf-fgtvm/ apply --auto-approve'
                 }
            }
    }
/*END FGT*/
/*DAST*/
    stage('DAST'){
            steps {
                 sh 'env | grep -E "JENKINS_HOME|BUILD_ID|GIT_BRANCH|GIT_COMMIT" > /tmp/env'
                 sh 'docker pull registry.fortidevsec.forticloud.com/fdevsec_dast:latest'
                 sh 'docker run --rm --env-file /tmp/env --mount type=bind,source=$PWD,target=/scan registry.fortidevsec.forticloud.com/fdevsec_dast:latest'
            }
    }
/*END DAST*/
  
}
}
