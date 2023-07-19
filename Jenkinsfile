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
      /*stage('SAST'){
            steps {
                 sh 'env | grep -E "JENKINS_HOME|BUILD_ID|GIT_BRANCH|GIT_COMMIT" > /tmp/env'
                 sh 'docker pull registry.fortidevsec.forticloud.com/fdevsec_sast:latest'
                 sh 'docker run --rm --env-file /tmp/env --mount type=bind,source=$PWD,target=/scan registry.fortidevsec.forticloud.com/fdevsec_sast:latest'
            }
        }*/
      stage('Deploy'){
            steps {
                 sh 'sed -i "s/<TAG>/${IMAGE_TAG}-${BUILD_NUMBER}/" deployment.yml'
                 sh 'sed -i "s/<APP_NAME>/${APP_NAME}/" deployment.yml'
                 sh 'kubectl apply -f deployment.yml'
                 /*sh 'sleep 15'
                 script {
                    env.EXTERNAL_IP = sh( script: 'kubectl get svc dvwa --output="jsonpath={.status.loadBalancer.ingress[0].hostname}"',
                    returnStdout: true).trim()
                    echo "teste ${env.EXTERNAL_IP}"
                 }
                 
                 /*
                 //If you are sure this deployment is already running and want to change the container image version, then you can use:
                 sh 'kubectl set image deployments/dvwa 371571523880.dkr.ecr.us-east-2.amazonaws.com/dvwaxperts:${BUILD_NUMBER}'*/
            }
        } 
       /*stage('DAST'){
            steps {
                 sh 'env | grep -E "JENKINS_HOME|BUILD_ID|GIT_BRANCH|GIT_COMMIT" > /tmp/env'
                 sh 'docker pull registry.fortidevsec.forticloud.com/fdevsec_dast:latest'
                 sh 'docker run --rm --env-file /tmp/env --mount type=bind,source=$PWD,target=/scan registry.fortidevsec.forticloud.com/fdevsec_dast:latest'
            }
        }*/
        stage('FortiWeb-Cloud'){
            steps {
                 //sh 'sleep 15'
                 script {
                    EXTERNAL_IP = sh( script: 'kubectl get svc dvwa --output="jsonpath={.status.loadBalancer.ingress[0].hostname}"',
                    returnStdout: true).trim()
                    //echo "teste ${EXTERNAL_IP}"
                    //sed -i "s/<EXTERNAL_LBIP>/${EXTERNAL_IP}/" tf-fwbcloud/tf-fwb.tf
                 }
                 sh 'echo "teste ${EXTERNAL_IP}"'
                 sh 'sed -i "s/<EXTERNAL_LBIP>/${EXTERNAL_IP}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<EXTERNAL_LBIP>/${EXTERNAL_IP}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<API_FWB_TOKEN>/${API_FWB_TOKEN}/" tf-fwbcloud/tf-fwb.tf'
                 sh 'sed -i "s/<APP_NAME>/${APP_NAME}/" tf-fwbcloud/tf-fwb.tf'
                 
                 sh 'cd tf-fwbcloud'
                 sh 'terraform init'
                 //sh 'terraform apply -auto-approve'                 
            }
        } 
    }
}
