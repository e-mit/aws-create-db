# Example parameters for creating an instance of this stack.
# Source this script, then run create.sh

KEY_NAME=testKey
STACK_NAME=testDBstack
KEY_FILENAME=key.pem

# Only this IP address will be allowed to SSH to the EC2 instance: 
ALLOWED_SSH_IP=$(curl -4 icanhazip.com)

# DB_PASSWORD -> define this separately
