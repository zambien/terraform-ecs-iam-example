# terraform-ecs-iam-example
Code to start you off with Terraform, ECS, and IAM access control.  This gives you a much better security posture than passing your secret keys all over the place.

## What you get
You will get an ecs cluster with one task running NGINX that restores a backup from S3 on instance startup and creates an hourly cron job to backup.  You also get all the networking bits necessary to route traffic to NGINX.  The container folder mount is:

```
instance: /ecs/nginx-home
container: /usr/share/nginx/html
```

The userdata will create an empty hello world index.html that can be modified and then it will automatically be backed up and restored.

## Security notes:

This is meant to be an example for IAM only.  Other security best practices are not implemented so that the example is clear and not muddied with other code that could be confusing.  For example:
    * The instance is exposed to the internet (public address is true).  This is generally a very bad idea.
    * The instance is open to SSH.  You should be using a bastion host to access your instances.
    * The instance is not patched.
    * NGINX is not locked down.

If there is enough interest in the project I will update this to have a proper DMZ, bastion host, load balancer, etc. to implement a more secure solution.

## Prerequisites

  * Terraform installed
  * A PRIVATE S3 bucket and object (key) already created
  * An AWS access and secret key with proper permissions
  * An ssh key created in AWS called terraform-key and put in your ~/.ssh folder. You may of course replace this in the variables file.

## Instructions

First, you need to provide your access key, secret key, and ssh key location to the environment.  Setup the following environment variables being sure to put the correct values.

```
export TF_VAR_access_key="Your AWS Access Key"
export TF_VAR_secret_key="Your AWS Secret Key"
export TF_VAR_key_name="terraform-key"
export TF_VAR_private_key_location="~/.ssh/terraform-key.pem"
export TF_VAR_s3_bucket="your-bucket-name"
export TF_VAR_s3_bucket_key="your-bucket-object/key/path"
```

If you have never used terraform before, check out the HashiCorp website:

https://www.terraform.io/

## Quick terraform crash course:  

To see what will be created:

```
terraform plan
```

To apply the plan (create everything in AWS):

```
terraform apply
```

To clean up (delete everything you created):

```
terraform destroy
```

### To connect to your instance

Log into the console or use the CLI to watch your instance start up and see your task start.  NGINX will be running on the instance dns, port 80.  For example: http://ec2-52-203-35-252.compute-1.amazonaws.com
