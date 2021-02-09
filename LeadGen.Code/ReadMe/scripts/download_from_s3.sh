#!/bin/bash

# set permissions  | chmod +x download_from_s3.sh |  chmod +x /opt/scripts/download_from_s3.sh
# run once         | ./download_from_s3.sh "$bucket" "$s3FilePath" "$filePath"

# Setting AWS credentials
. set_aws_credentials.sh

# Extract Arguments
bucket="$1"
s3FilePath="$2"
filePath="$3"

# DOWNLOAD FROM S3
echo "Downloading from AWS S3:"
echo " bucket:\"${bucket}\" path:\"${s3FilePath}\""
echo " TO ${filePath}"

rm -f "$filePath"

resource="/${bucket}/${s3FilePath}"
contentType="application/binary"
dateValue=`date -R`
stringToSign="GET\n\n${contentType}\n${dateValue}\n${resource}"
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${AWSsecret} -binary | base64`
sudo curl -H "Host: ${bucket}.s3.amazonaws.com" \
 -H "Date: ${dateValue}" \
 -H "Content-Type: ${contentType}" \
 -H "Authorization: AWS ${AWSkey}:${signature}" \
 http://${bucket}.s3.amazonaws.com/${s3FilePath} -o "${filePath}"
