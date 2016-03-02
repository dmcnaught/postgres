#!/usr/bin/env bash

cd "$WALE_ENVDIR"

# access-key-id and access-secret-key files are mounted in via kubernetes secrets
AWS_ACCESS_KEY_ID=$(cat access-key-id)
AWS_SECRET_ACCESS_KEY=$(cat access-secret-key)

# setup envvars for wal-e
cp access-key-id AWS_ACCESS_KEY_ID
cp access-secret-key AWS_SECRET_ACCESS_KEY
echo "http://$DEIS_MINIO_SERVICE_HOST:$DEIS_MINIO_SERVICE_PORT" > WALE_S3_ENDPOINT
echo "s3://$BUCKET_NAME" > WALE_S3_PREFIX
if [ "$S3_URL" == "" ]; then
  echo "http://$DEIS_MINIO_SERVICE_HOST:$DEIS_MINIO_SERVICE_PORT" > S3_URL
fi


# setup boto config
mkdir -p /root/.aws /home/postgres/.aws

cat << EOF > /root/.aws/credentials
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF

# HACK (bacongobbler): minio *must* use us-east-1 and signature version 4
# for authentication.
# see https://github.com/minio/minio#how-to-use-aws-cli-with-minio
cat << EOF > /root/.aws/config
[default]
region = us-east-1
s3 =
    signature_version = s3v4
EOF


# write AWS config to postgres homedir as well
cp /root/.aws/* /home/postgres/.aws/
chown -R postgres:postgres /home/postgres