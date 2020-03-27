#!/bin/bash

echo "hello $1"

if [ "$*" = "" ]; then
    echo "No arguments provided"
    exit 1
fi

# We expect part and md5sum files, so need to remove the extension
FILENAME=`echo "$1" | sed "s/minio_host\/rx\-in\///g" | sed "s/-part[a-z]*//g" | sed "s/.md5sum//g"`
echo "FILENAME: $FILENAME"

if mc stat "minio_host/$MINIO_RX_IN_BUCKET_NAME/$FILENAME.md5sum"; then

    mc cp --recursive "minio_host/$MINIO_RX_IN_BUCKET_NAME/$FILENAME.md5sum" /app/tmp/
    MD5LINE="/app/tmp/$FILENAME.md5sum"
    echo "$MD5LINE"

    while IFS= read -r LINE; do
        PARTFILENAME=`echo "$LINE" | awk '{print $2}'`
        echo "checking $PARTFILENAME"
        if mc stat "minio_host/$MINIO_RX_IN_BUCKET_NAME/$PARTFILENAME" ; then
            echo "$PARTFILENAME arived"
        else
            echo "$PARTFILENAME never arrive or copied already"
            exit 1
        fi
    done <<<`awk 'NR>1' "$MD5LINE"`

    # Copy all files to tmp
    while IFS= read -r LINE; do
        PARTFILENAME=`echo "$LINE" | awk '{print $2}'`
        echo "copying $PARTFILENAME"
        mc cp "minio_host/$MINIO_RX_IN_BUCKET_NAME/$PARTFILENAME" /app/tmp/
    done <<<`awk 'NR>1' "$MD5LINE"`

    # Join, compare md5 and put in object storage
    cat "/app/tmp/$FILENAME-part"* > "/app/tmp/$FILENAME"
    FILEHASH=`md5sum /app/tmp/$FILENAME | awk '{print $1}'`
    SOURCEFILEHASH=`head -n 1 "/app/tmp/$FILENAME.md5sum" | awk '{print $1}'`
    echo $FILEHASH
    echo $SOURCEFILEHASH
    if [ "$FILEHASH" == "$SOURCEFILEHASH" ] ; then
        echo "md5 matches!"
        mc cp "/app/tmp/$FILENAME" "minio_host/$MINIO_RX_OUT_BUCKET_NAME/$FILENAME" 
    else
        echo "md5 doesn't match"   
    fi
    
    # Cleanup
    echo "cleaning up /app/tmp/$FILENAME*"
    rm "/app/tmp/$FILENAME"*
    mc find minio_host/$MINIO_RX_IN_BUCKET_NAME --name "$FILENAME"* | xargs -i mc rm {}

    # Cat part files
else
    echo "md5sum hasen't arrived for $FILENAME"
    exit 1
fi