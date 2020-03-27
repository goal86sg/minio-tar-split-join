FROM minio/mc:latest
RUN apk add --no-cache bash
WORKDIR /app
COPY . /app
RUN chmod +x /app/wait-for-it.sh