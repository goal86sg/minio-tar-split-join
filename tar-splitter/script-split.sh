#!/bin/bash
mc config host add minio_host http://minio:9000 testingtesting123 testingtesting123 --api S3v4
echo "Ready for file upload"
mc find minio_host/to-split --name '*' --watch | xargs -i /app/tar-split.sh "{}"