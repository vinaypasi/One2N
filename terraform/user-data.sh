#!/bin/bash
# Update and install dependencies
sudo yum update -y
sudo yum install -y python3 git pip


# Clone the repository
wget https://raw.githubusercontent.com/vinaypasi/One2N/main/app.py -O ~/app.py

# Install Python dependencies
sudo pip3 install flask boto3

# Export bucket name (update as necessary)
sudo export BUCKET_NAME=one2nbucketlisting
sudo openssl genpkey -algorithm RSA -out server-key.pem
sudo openssl req -new -key server-key.pem -out server-csr.pem -subj "/C=US/ST=State/L=City/O=Company/OU=Dev/CN=localhost"
sudo openssl x509 -req -in server-csr.pem -signkey server-key.pem -out server-cert.pem
# Run the app
nohup python3 ~/app.py > app.log 2>&1 &
