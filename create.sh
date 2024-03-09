#!/bin/bash

# Prevent terminal output waiting:
export AWS_PAGER=""

KEY_NAME=testKey
STACK_NAME=testDBstack
KEY_FILENAME=key.pem
MY_IP=$(curl -4 icanhazip.com)

if [[ -z $DB_PASSWORD ]]; then
    echo ERROR: DB_PASSWORD is not set
    exit 1
fi

# Create new key pair and save the private key to file
aws ec2 create-key-pair \
--key-name $KEY_NAME | jq -r '.KeyMaterial' > $KEY_FILENAME
chmod go-rw $KEY_FILENAME

# Create the stack
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://template.yml \
--parameters ParameterKey=keyname,ParameterValue=$KEY_NAME \
ParameterKey=DBPassword,ParameterValue=$DB_PASSWORD \
ParameterKey=allowedIP,ParameterValue=$MY_IP

read -p "Press any key to continue... " -n1 -s; echo

# get DB endpoint:
DB_ENDPOINT=$(aws rds describe-db-instances \
--db-instance-identifier testdbi | \
python3 -c "import sys, json
print(json.load(sys.stdin)['DBInstances'][0]['Endpoint']['Address'])")

# Get the EC2 instance ID
EC2_ID=$(aws cloudformation describe-stack-resource \
--stack-name $STACK_NAME \
--logical-resource-id MyEC2Instance | \
python3 -c "import sys, json
print(json.load(sys.stdin)['StackResourceDetail']['PhysicalResourceId'])")

# Get the EC2 public IP address:
EC2_IP=$(aws ec2 describe-instances \
--instance-ids $EC2_ID | \
python3 -c "import sys, json
print(json.load(sys.stdin)['Reservations'][0]['Instances'][0]['PublicIpAddress'])")

# SSH to the EC2
ssh -t -i $KEY_FILENAME -o StrictHostKeyChecking=accept-new \
    ec2-user@$EC2_IP \
    PGPASSWORD=$DB_PASSWORD DB_ENDPOINT=$DB_ENDPOINT bash -l

# Then connect to the database from the EC2:
if (( 0==1 )); then
    # Run this over SSH
    sudo dnf update -y
    sudo dnf install -y postgresql15 # NB: only version available
    psql --host=$DB_ENDPOINT --port=5432 \
        --dbname=postgres --username=dbuser
fi

read -p "Press any key to continue... " -n1 -s; echo

# delete the stack (this deletes all resources within it):
aws cloudformation delete-stack --stack-name $STACK_NAME

aws ec2 delete-key-pair \
--key-name $KEY_NAME

rm -f $KEY_FILENAME
