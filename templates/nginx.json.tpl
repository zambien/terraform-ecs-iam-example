[
  {
    "name": "nginx",
    "image": "nginx",
    "cpu": 128,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "nginx-home",
        "containerPath": "/usr/share/nginx/html"
      }
    ]
  }
]
