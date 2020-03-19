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
MINIO_SERVER_SOURCE_HOST=http://host:9000
MINIO_SERVER_SOURCE_BUCKET_NAME=source
MINIO_SERVER_SOURCE_ACCESS_KEY=testingtesting123
MINIO_SERVER_SOURCE_SECRET_KEY=testingtesting123

MINIO_SERVER_TARGET_HOST=http://host:9000
MINIO_SERVER_TARGET_BUCKET_NAME=destination
MINIO_SERVER_TARGET_ACCESS_KEY=testingtesting123
MINIO_SERVER_TARGET_SECRET_KEY=testingtesting123
```

