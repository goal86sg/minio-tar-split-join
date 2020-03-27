FROM minio/mc:latest
RUN apk add --no-cache bash
RUN chmod +x /app/wait-for-it.sh
WORKDIR /app
COPY . /app