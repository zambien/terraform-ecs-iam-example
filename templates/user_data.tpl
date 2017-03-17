#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "USER_DATA BEGIN " `date`

echo "Setting ECS_CLUSTER into /etc/ecs/ecs.config"
echo ECS_CLUSTER='${ecs_cluster_name}' > /etc/ecs/ecs.config

echo "Create and set correct permissions for backup mount directory"
backup_host_dir=/ecs/nginx-home
mkdir -p $backup_host_dir
chmod -R 777 $backup_host_dir

echo "Creating empty index.html"
cat <<EOF > /ecs/nginx-home/index.html
  <!DOCTYPE html>
  <html>
  <head>
  <title>Welcome to nginx!</title>
  <style>
      body {
          width: 35em;
          margin: 0 auto;
          font-family: Tahoma, Verdana, Arial, sans-serif;
      }
  </style>
  </head>
  <body>
  <h1>Welcome to nginx!</h1>
  <p>You can make changes to /usr/share/nginx/html and they will be backed up hourly!.</p>
  <p>If you want to run a backup manually go onto the instance host and run sudo /etc/cron.hourly/backup_files</p>

  <p><em>Thank you for playing.</em></p>
  </body>
  </html>
EOF

# no creds are neccessary since the instance has access to the bucket
echo "restore_backup is: " ${restore_backup}
if ${restore_backup}; then
    echo "restoring backup"

    docker run \
    --env cmd=sync-s3-to-local \
    --env SRC_S3=s3://${s3_bucket}/${s3_bucket_key}${ecs_cluster_name}/${restore_point}/backup-home/  \
    -v $backup_host_dir:/opt/dest \
    zambien/docker-s3cmd
fi
echo "setting appropriate permissions in $backup_host_dir for typical nginx ecs guid"
sudo chown -R 500:500 $backup_host_dir/*

echo "Creating hourly cron backup"
# no creds are neccessary since the instance has access to the bucket
cat <<EOF > /etc/cron.hourly/backup_files
#!/bin/bash

# Backup script for backup via docker task

/usr/bin/docker run --rm --env cmd=sync-local-to-s3 \
--env DEST_S3=s3://${s3_bucket}/${s3_bucket_key}${ecs_cluster_name}/hourly/ \
-v $backup_host_dir:/opt/src/nginx-home \
zambien/docker-s3cmd \
> /tmp/backup_hourly.log
EOF

sudo chmod 755 /etc/cron.hourly/backup_files

echo "USER_DATA END " `date '+%Y-%m-%d %H:%M:%S'`
