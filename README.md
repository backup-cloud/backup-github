# backup-github

Repository that contains the script responsible for the backup of the github. 
This repo contains as well a dockerfile in order to be possible to perform the backup using fargate.

In order to perform correctly, a private key that has access to the github repos you want to backup, 
must be present in the root folder with the name of id_rsa in order to be copied to the container.

After the container is created and pushed to a docker repo, a task specification must be created in order to be able to perform the backup.

Using fargate cli:

fargate task run backup-github --region $REGION --image $DOCKER_IMAGE_PUSHED -e GITHUB_ORG=$GITHUB_ORGANIZATION -e GITHUB_TOKEN=$TOKEN -e S3_BUCKET=$S3_BUCKET_BAK -e AWS_ACCESS_KEY_ID=$AWS_ACCESS -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET --subnet-id $SUBNET1 --subnet-id subnet-$SUBNET2 --security-group-id $SEC_GROUP


Substitute the following variables with the settings you would need to:

  - $REGION: aws region where the fargate cluster is located;
  - $DOCKER_IMAGE_PUSHED: docker image build using the dockerfile present in this repo;
  - $GITHUB_ORGANIZATION: name of the github organization who owns the repos to perform the backup;
  - $TOKEN: github token to access the repositories;
  - $S3_BUCKET_BAK: name of the s3 bucket where the backup will be temp stored;
  - $AWS_ACCESS: aws access key with permissions to push to the bucket;
  - $AWS_SECRET: aws secret key that matches the acess key;
  - $SUBNET1: subnet for fargate cluster to be deployed on
  - $SUBNET2: subnet for fargate cluster to be deployed on
  - $SEC_GROUP: security group to be applied to the fargate cluster

