#!/bin/sh

rm -rf ./tmp/*
mc rm --force minio_host/split
mc rm --force minio_host/to-split
mc rm --force minio_host/joined
mc rm --force minio_host/to-join