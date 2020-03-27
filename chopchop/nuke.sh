#!/bin/sh

mc find minio_host/split | xargs -i mc rm {}
mc find minio_host/to-split | xargs -i mc rm {}
mc find minio_host/joined | xargs -i mc rm {}
mc find minio_host/to-join | xargs -i mc rm {}