#!/bin/bash
aws s3api create-bucket --bucket alexander-stepanov123 --region us-east-1
echo '<!DOCTYPE html><html><head><title>My S3 Bucket</title></head><body><h1>Welcome to my S3 Bucket</h1><p>The name of this bucket is: <strong>alexander-stepanov123</strong></p></body></html>' > index.html
echo '<!DOCTYPE html><html><head><title>404 - Not Found</title></head><body><h1>Oops! Something went wrong.</h1><p>The requested resource was not found on this server.</p></body></html>' > error.html

cat > bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::alexander-stepanov123/*"
    }
  ]
}
EOF
sleep 6
aws s3 cp index.html s3://alexander-stepanov123
aws s3 cp error.html s3://alexander-stepanov123
aws s3api put-public-access-block --bucket alexander-stepanov123 --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false
aws s3 website s3://alexander-stepanov123/ --index-document index.html --error-document error.html
sleep 5
aws s3api put-bucket-policy --bucket alexander-stepanov123 --policy file://bucket-policy.json
rm index.html
rm error.html
rm bucket-policy.json
