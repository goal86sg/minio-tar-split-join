#!/bin/bash

echo "hello $1"

if [ "$*" = "" ]; then
    echo "No arguments provided"
    exit 1
fi

# We expect part and md5sum files, so need to remove the extension
FILENAME=`echo "$1" | sed 's/minio_host\/split\///g' | sed 's/-part[a-z]*//g' | sed 's/.md5sum//g'`
echo "FILENAME: $FILENAME"

if mc stat "minio_host/split/$FILENAME.md5sum"; then

    mc cp "minio_host/split/$FILENAME.md5sum" ./tmp/
    MD5LINE="./tmp/$FILENAME.md5sum"
    echo "$MD5LINE"

    while IFS= read -r LINE; do
        PARTFILENAME=`echo "$LINE" | awk '{print $2}'`
        echo "checking $PARTFILENAME"
        if mc stat "minio_host/split/$PARTFILENAME" ; then
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
        mc cp "minio_host/split/$PARTFILENAME" ./tmp/
    done <<<`awk 'NR>1' "$MD5LINE"`

    # Join, compare md5 and put in object storage
    cat "./tmp/$FILENAME-part"* > "./tmp/$FILENAME"
    FILEHASH=`md5sum ./tmp/ndp48.txt | awk '{print $1}'`
    SOURCEFILEHASH=`head -n 1 "./tmp/$FILENAME.md5sum" | awk '{print $1}'`
    echo $FILEHASH
    echo $SOURCEFILEHASH
    if [ "$FILEHASH" == "$SOURCEFILEHASH" ] ; then
        echo "md5 matches!"
        mc cp "./tmp/$FILENAME" "minio_host/joined/$FILENAME" 
    else
        echo "md5 doesn't match"   
    fi
    
    # Cleanup
    rm "./tmp/$FILENAME"*
    mc find minio_host/split/ --name "ndp48.txt"* | xargs -i mc rm {}

    # Cat part files
else
    echo "md5sum hasen't arrived for $FILENAME"
    exit 1
fi

#mc find . --maxdepth 1 --name $FILENAME.md5sum | xargs -i md5sum {} > ./$FILENAME.md5sum