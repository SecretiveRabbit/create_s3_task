#!/bin/bash

# Set the initial values for the variables
score_max=4
score_current=0
ip_address="54.209.183.77"
username="alexander"
token_name="supertoken"
token_value="11e4336999ba2df92e4aed4d39e0badb74"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -a|--ip-address)
      ip_address="$2"
      shift 2
      ;;
    -u|--username)
      username="$2"
      shift 2
      ;;
    -n|--token-name)
      token_name="$2"
      shift 2
      ;;
    -v|--token-value)
      token_value="$2"
      shift 2
      ;;
    -s|--site-name)
      site_name="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Get the last build number before triggering the job
last_build_before_triggering=$(curl -s -u "${username}:${token_value}" http://${ip_address}:8080/job/create_s3_bucket/lastBuild/buildNumber)

# Trigger the Jenkins job and capture the output
jenkins_output=$(curl -s -u "${username}:${token_value}" http://${ip_address}:8080/job/create_s3_bucket/buildWithParameters\?token\=${token_name}\&test1\=test2\&jenk\=dsa)

# Check if the output is empty
if [ -z "$jenkins_output" ]; then
    # If the output is empty, increment the score_current variable
    ((score_current++))
    echo "The Jenkins Job was triggered"
fi

# Sleep for 10 seconds
sleep 10

# Get the last build number after triggering the job
last_build_after_triggering=$(curl -s -u "${username}:${token_value}" http://${ip_address}:8080/job/create_s3_bucket/lastBuild/buildNumber)

# Compare the last build numbers and increment the score_current variable if they're different
if [ "$last_build_before_triggering" != "$last_build_after_triggering" ]; then
    ((score_current++))
    echo "The Jenkins Job was started"
fi

# Check if the Jenkins job completed successfully
for i in {1..10}; do
    echo "Checking if the Jenkins job is completed successfully (attempt $i)"
    result=$(curl -s -u "${username}:${token_value}" http://${ip_address}:8080/job/create_s3_bucket/lastBuild/api/json -H "Content-Type: application/json" -X GET | grep '"result":"SUCCESS"')
    if [ $? -eq 0 ]; then
        echo "The Jenkins Job is completed successfully"
        ((score_current++))
        break
    else
        sleep 10
    fi
done

if [ $? -ne 0 ]; then
    echo "The Jenkins Job failed or didn't complete"
fi

# Check if the S3 Static Web Site is created
if [ -z "$site_name" ]; then
    site_name="alexander-stepanov123"
fi
s3_output=$(curl -s https://${site_name}.s3-website-us-east-1.amazonaws.com)
if [[ "$s3_output" == *"${site_name}"* ]]; then
    ((score_current++))
    echo "The S3 Static Site works"
else
    echo "It seems something is wrong with the Static S3 Web Site"
fi

echo "Current score: $score_current out of $score_max"
