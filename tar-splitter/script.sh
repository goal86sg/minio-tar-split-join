#!/bin/bash
mc config host add minio_host http://minio:9000 testingtesting123 testingtesting123 --api S3v4
mc find minio_host/source --name '*' --watch --exec '/app/tar-split.sh {}'