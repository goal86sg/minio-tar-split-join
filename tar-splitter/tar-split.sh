#!/bin/bash
SECONDS=0
start=SECONDS

echo "hello $1"

if [ "$*" = "" ]; then
    echo "No arguments provided"
    exit 1
fi

FILENAME=`echo "$1" | sed 's/minio_host\/to-split\///g'`

#TODO, CATCH NESTED BUCKET
#TODO PARAMETIZE minio/bucket

echo "$FILENAME"

# Tar the object
DATE=`date -Iseconds` && \
mc cp "$1" "./tmp/$FILENAME"

# Split the object
echo "Splitting $FILENAME"
split -b 50m "./tmp/$FILENAME" "./tmp/$FILENAME-part"
time_split=$SECONDS
mc find ./tmp/ --name "$FILENAME" --print {base} | xargs -i md5sum ./tmp/{} | sed 's/\.\/tmp\///g' >> "./tmp/$FILENAME.md5sum"
rm "./tmp/$FILENAME"
echo "MD5-ing $FILENAME"
mc find ./tmp/ --name "$FILENAME-part*" --print {base} | xargs -i md5sum ./tmp/{} | sed 's/\.\/tmp\///g' >> "./tmp/$FILENAME.md5sum"
time_md5=$SECONDS
sed -i 's/\./tmp\///g' "./tmp/$FILENAME.md5sum"
cat "./tmp/$FILENAME.md5sum" 

echo "copying ./tmp/$FILENAME-* to minio_host/split/"
mc cp "./tmp/$FILENAME."* minio_host/split/
mc cp "./tmp/$FILENAME-"* minio_host/split/

rm "./tmp/$FILENAME-"* "./tmp/$FILENAME."*
mc rm "$1"

time_end=$SECONDS

splittime=$((time_split-start))
md5time=$((time_md5-time_split))
runtime=$((time_end))
echo "Finished processing $1 in '$runtime's, splittime = '$splittime's, md5time = '$md5time's"