#!/bin/sh

echo "hello $1"

if [ "$*" == "" ]; then
    echo "No arguments provided"
    exit 1
fi

# We expect part and md5sum files, so need to remove the extension
FILENAME=`echo "$1" | sed 's/minio_host\/split\///g' | sed 's/.tar-part[a-z]*//g' | sed 's/.md5sum//g'`
echo $FILENAME

if mc cp $FILENAME.md5sum ./tmp/ ; then
    echo "Do the rest of the script here"
    # Check if all files arived
    
    # Copy all partial files to tmp
    mc cp $FILENAME.tar-part* ./tmp/

    # Cat part files
else
    echo "md5sum hasen't arrived for $FILENAME"
fi

mc find . --maxdepth 1 --name $FILENAME.md5sum | xargs -i md5sum {} > ./$FILENAME.tar.md5sum