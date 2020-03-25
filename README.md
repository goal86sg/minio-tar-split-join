# tar-splitter - WIP
tar-splitter picks up files from a MinIO bucket, tars and splits them into smaller chunks into target MinIO bucket

## Start dev minio server
```
docker-compose up
```

## Reference
```
mc find minio_host/source --name "*" --watch --exec "./tar-split.sh {}"
```

## Start interactice minio client container
```
# Configre minio host
docker run -it --entrypoint=/bin/sh minio/mc
mc config host add minio_host http://platform.net:9000 testingtesting123 testingtesting123 --api S3v4

# Tar the object
DATE=`date -Iseconds` && \
mc cp minio_host/source/VSCodeUserSetup-x64-1.28.2.exe /tmp
tar -cvzf $DATE-VSCodeUserSetup-x64-1.28.2.exe.tar.gz /tmp/VSCodeUserSetup-x64-1.28.2.exe
rm /tmp/VSCodeUserSetup-x64-1.28.2.exe

# Split the object
split -b 10m $DATE-VSCodeUserSetup-x64-1.28.2.exe.tar.gz "$DATE-VSCodeUserSetup-x64-1.28.2.exe.tar.gz-part"
ls .
mc find . --maxdepth 1 --name '20*-part*' --exec 'mc cp -q {} minio_host/destination/{base}'
mc ls minio_host/destination/
rm $DATE-VSCodeUserSetup-x64-1.28.2.exe.tar.gz*
ls .
```




Set up .env variables
```
MINIO_SERVER_TO_SPLITHOST=http://host:9000
MINIO_SERVER_TO_SPLITBUCKET_NAME=to-split
MINIO_SERVER_TO_SPLITACCESS_KEY=testingtesting123
MINIO_SERVER_TO_SPLITSECRET_KEY=testingtesting123

MINIO_SERVER_SPLIT_HOST=http://host:9000
MINIO_SERVER_SPLIT_BUCKET_NAME=split
MINIO_SERVER_SPLIT_ACCESS_KEY=testingtesting123
MINIO_SERVER_SPLIT_SECRET_KEY=testingtesting123


MINIO_SERVER_TO_JOINHOST=http://host:9000
MINIO_SERVER_TO_JOINBUCKET_NAME=to-join
MINIO_SERVER_TO_JOINACCESS_KEY=testingtesting123
MINIO_SERVER_TO_JOINSECRET_KEY=testingtesting123

MINIO_SERVER_JOINED_HOST=http://host:9000
MINIO_SERVER_JOINED_BUCKET_NAME=joined
MINIO_SERVER_JOINED_ACCESS_KEY=testingtesting123
MINIO_SERVER_JOINED_SECRET_KEY=testingtesting123
```

