#!/bin/bash

# Prevent terminal output waiting:
export AWS_PAGER=""

KEY_NAME=testKey
STACK_NAME=testDBstack

# Create new key pair and save the private key to file
aws ec2 create-key-pair \
--key-name $KEY_NAME | jq -r '.KeyMaterial' > key.txt

# Create the stack
aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://template.yml \
--parameters ParameterKey=keyname,ParameterValue=$KEY_NAME

read -p "Press any key to continue... " -n1 -s; echo

# delete the stack (this deletes all resources within it):
aws cloudformation delete-stack --stack-name $STACK_NAME

aws ec2 delete-key-pair \
--key-name $KEY_NAME
