#!/bin/sh

echo "hello $1"

if [ "$*" == "" ]; then
    echo "No arguments provided"
    exit 1
fi

FILENAME=`echo "$1" | sed 's/minio_host\/source\///g'`

#TODO, CATCH NESTED BUCKET
#TODO PARAMETIZE minio/bucket

echo $FILENAME

# Tar the object
DATE=`date -Iseconds` && \
mc cp $1 /tmp/$FILENAME
tar 
tar -cvf $FILENAME.tar /tmp/$FILENAME
rm /tmp/$FILENAME

# Split the object
split -b 500m $FILENAME.tar "$FILENAME.tar-part"
mc find . --maxdepth 1 --name '*-part*' --exec 'mc cp -q {} minio_host/destination/{base}'
rm $FILENAME.tar*