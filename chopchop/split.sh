#!/bin/bash
SECONDS=0
start=SECONDS

echo "hello $1"

if [ "$*" = "" ]; then
    echo "No arguments provided"
    exit 1
fi

FILENAME=`echo "$1" | sed "s/minio_host\/tx\-in\///g"`

#TODO, CATCH NESTED BUCKET
#TODO PARAMETIZE minio/bucket

echo "$FILENAME"

# Tar the object
DATE=`date -Iseconds` && \
mc cp "$1" "/app/tmp/$FILENAME"

# Split the object
echo "Splitting $FILENAME"
split -b 50m "/app/tmp/$FILENAME" "/app/tmp/$FILENAME-part"
time_split=$SECONDS
mc find /app/tmp/ --name "$FILENAME" --print {base} | xargs -i md5sum /app/tmp/{} | sed "s/\/app\/tmp\///g" >> "/app/tmp/$FILENAME.md5sum"
rm "/app/tmp/$FILENAME"
echo "MD5-ing $FILENAME"
mc find /app/tmp/ --name "$FILENAME-part*" --print {base} | xargs -i md5sum /app/tmp/{} | sed "s/\/app\/tmp\///g" >> "/app/tmp/$FILENAME.md5sum"
time_md5=$SECONDS
sed -i "s/\./tmp\///g" "/app/tmp/$FILENAME.md5sum"
cat "/app/tmp/$FILENAME.md5sum" 

echo "copying /app/tmp/$FILENAME-* to minio_host/$MINIO_TX_OUT_BUCKET_NAME"
mc cp "/app/tmp/$FILENAME."* "minio_host/$MINIO_TX_OUT_BUCKET_NAME"
mc cp "/app/tmp/$FILENAME-"* "minio_host/$MINIO_TX_OUT_BUCKET_NAME"

rm "/app/tmp/$FILENAME-"* "/app/tmp/$FILENAME."*
mc rm "$1"

time_end=$SECONDS

splittime=$((time_split-start))
md5time=$((time_md5-time_split))
runtime=$((time_end))
echo "Finished processing $1 in '$runtime's, splittime = '$splittime's, md5time = '$md5time's"