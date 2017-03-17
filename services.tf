data "template_file" "nginx_task_template" {
  template = "${file("templates/nginx.json.tpl")}"
}

resource "aws_ecs_task_definition" "nginx" {
  family                = "${var.tag_name}-web-task"
  container_definitions = "${data.template_file.nginx_task_template.rendered}"

  volume {
    name      = "nginx-home"
    host_path = "/ecs/nginx-home"
  }

  depends_on = [
    "aws_autoscaling_group.asg_nginx",
  ]
}

resource "aws_ecs_service" "nginx" {
  name    = "${var.tag_name}-svc"
  cluster = "${aws_ecs_cluster.nginx.id}"

  task_definition = "${aws_ecs_task_definition.nginx.arn}"

  desired_count = "${var.desired_service_count}"

  depends_on = [
    "aws_autoscaling_group.asg_nginx",
  ]
}
