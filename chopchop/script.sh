#!/bin/bash
mc config host add minio_host $MINIO_HOST $MINIO_ACCESS_KEY $MINIO_SECRET_KEY --api S3v4

if [ "$TX" = "TRUE" ]; then
    mc mb --ignore-existing minio_host/$MINIO_TX_IN_BUCKET_NAME
    mc mb --ignore-existing minio_host/$MINIO_TX_OUT_BUCKET_NAME
    mc find minio_host/$MINIO_TX_IN_BUCKET_NAME --name '*' --watch | xargs -i /app/split.sh "{}"
elif [ "$RX" = "TRUE" ]; then
    mc mb --ignore-existing minio_host/$MINIO_RX_IN_BUCKET_NAME
    mc mb --ignore-existing minio_host/$MINIO_RX_OUT_BUCKET_NAME
    mc find minio_host/$MINIO_RX_IN_BUCKET_NAME --name '*' --watch | xargs -i /app/join.sh "{}"
fi
