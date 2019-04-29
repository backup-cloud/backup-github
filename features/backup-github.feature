Feature: backup data from Paddle's Github Repositories

In order provide backups of our Github data, paddle system engineering
team would like to have a system which makes a backup of the current Github Repositories into an S3 location.

    
    Scenario: store  backup in S3
    given that I have configured a lambda in AWS
     and that I have the bash script to perform the backup
     and that I have created a fargate task
     and that I have an S3 backup bucket where I have write access
     and that I have a file in S3 to backup
     and that I have an ECS role which gives me all needed permissions
    when I run my backup container giving the base path
    then a backup should be created in the S3 destination bucket
     and that backup should contain my data

    @wip
    Scenario: backup the github repos with encryption then restore with decryption
    given I have a private public key pair
        and that my s3 bucket is empty
        when I run a backup on the github repo's using the public key
        and I restore that backup of the github repo's using the private key
        then the s3 bucket should not contain unencrypted data
        and the data from the original repo should be in the new repo