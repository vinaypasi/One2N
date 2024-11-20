
# S3 Bucket Content Listing Service

## Overview

This repository contains:
- A Python HTTP service that lists the contents of an AWS S3 bucket.
- Terraform code to deploy the service on AWS infrastructure.

The service exposes a single endpoint:  
`GET /list-bucket-content/<path>`  
- Returns the contents of the specified S3 bucket path.
- If no path is provided, returns the top-level content.

## Features
- Lists S3 bucket content in JSON format.
- Handles non-existent paths with appropriate error messages.
- Has self-signed certificate for https service deployment.
- Can be deployed on HTTPS using AWS ACM and ALB (optional).

## Prerequisites
- AWS account with access to create S3, EC2, and IAM resources.
- Terraform installed (v1.5 or later).
- Python 3.x installed.

## Project Structure

```
├── app.py                 # Python HTTP service
├── requirements.txt       # Python dependencies
├── terraform/
│   ├── main.tf            # Terraform configuration
│   ├── variables.tf       # Terraform variables
│   ├── outputs.tf         # Terraform outputs
│   └── user_data.sh       # EC2 startup script for Python service
├── README.md              # Project documentation
└── demo/                  # Screenshots and video demo
```

## Instructions

### Part 1: HTTP Service

1. Clone this repository:
   ```bash
   git clone https://github.com/username/repository.git
   cd repository
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Set environment variables:
   ```bash
   export BUCKET_NAME=<your-s3-bucket-name>
   ```

4. Run the service:
   ```bash
   python app.py
   ```

5. Access the service:
   - Example: `http://localhost:5000/list-bucket-content`
   - Example: `http://localhost:5000/list-bucket-content/dir1`

### Part 2: Terraform Deployment

1. Navigate to the `terraform` folder:
   ```bash
   cd terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the infrastructure:
   ```bash
   terraform plan -var="bucket_name=<your-s3-bucket-name>"
   ```

4. Apply the configuration:
   ```bash
   terraform apply -var="bucket_name=<your-s3-bucket-name>"
   ```

5. Once the deployment is complete:
   - Access the service using the EC2 public IP: `https://<EC2_PUBLIC_IP>:443/list-bucket-content`.

6. (Optional) For HTTPS:
   - Update the Terraform configuration to include an Application Load Balancer (ALB) and an ACM certificate.

### Demo

- Screenshots of the deployed service and S3 bucket structure are available in the `demo` folder.
- A video demonstration of the deployment process and service functionality is provided.

## Error Handling

- Non-existing paths return a `404` error with a descriptive message.
- Invalid bucket or AWS configuration issues return a `500` error.

## Cleanup

After testing, remember to clean up the resources to avoid incurring charges:
```bash
terraform destroy -var="bucket_name=<your-s3-bucket-name>"
```

## Design Decisions

- **Flask**: Lightweight framework for the HTTP service.
- **Boto3**: Simplifies S3 operations.
- **Terraform**: Infrastructure as code for easy reproducibility and scalability.
- **Error Handling**: Ensures robust responses for different scenarios.
- **Security**: Use of IAM roles for S3 access and option to deploy HTTPS.

## Assumptions
- The S3 bucket already exists.
- The deployed service has read permissions for the bucket.

## Improvements
- Add authentication for enhanced security.
- Automate HTTPS setup with Terraform.
