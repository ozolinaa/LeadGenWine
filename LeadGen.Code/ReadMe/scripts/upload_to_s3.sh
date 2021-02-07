#!/bin/bash

# set permissions  | chmod +x upload_to_s3.sh |  chmod +x /opt/scripts/upload_to_s3.sh
# run once         | ./upload_to_s3.sh "$filePath" "$bucket" "$bucketPath"

# Setting AWS credentials
. set_aws_credentials.sh

# Extract Arguments
filePath="$1"
bucket="$2"
bucketPath="$3"

# Extract fileName (checking both windows "\" and unix "/" separators)
fileName=${filePath##*/}
fileName=${fileName##*\\}

# Build fileNameToUpload (append current datetime to fileName)
now=$(date +"%Y_%m_%d_%H_%M_%S")
fileNameToUpload="${fileName%.*}_${now}.${fileName##*.}"

s3FilePath="${bucketPath}/${fileNameToUpload}"

# UPLOAD TO S3
echo "Uploading to AWS S3:"
echo " FROM ${filePath}"
echo " TO bucket:\"${bucket}\" path:\"${s3FilePath}\""

resource="/${bucket}/${s3FilePath}"
contentType="application/binary"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"

signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${AWSsecret} -binary | base64`
curl -L -X PUT -T "${filePath}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${AWSkey}:${signature}" \
  http://${bucket}.s3.amazonaws.com/${s3FilePath}
