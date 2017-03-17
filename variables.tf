variable "access_key" {}
variable "secret_key" {}
variable "s3_bucket" {}
variable "s3_bucket_key" {}

variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default     = "terraform-key"
  description = "SSH key name in your AWS account for AWS instances."
}

variable "availability_zone" {
  default = "us-east-1b"
}

variable "amis" {
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."

  default = {
    us-east-1      = "ami-8f7687e2"
    us-west-1      = "ami-bb473cdb"
    us-west-2      = "ami-84b44de4"
    eu-west-1      = "ami-4e6ffe3d"
    eu-central-1   = "ami-b0cc23df"
    ap-northeast-1 = "ami-095dbf68"
    ap-southeast-1 = "ami-cf03d2ac"
    ap-southeast-2 = "ami-697a540a"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "min_instance_size" {
  default = 1
}

variable "max_instance_size" {
  default = 2
}

variable "desired_instance_capacity" {
  default = 1
}

variable "desired_service_count" {
  default = 1
}

variable "restore_backup" {
  default = "false"
}

variable "restore_point" {
  default = "hourly"
}

variable tag_name {
  default = "ecs-iam-example"
}
