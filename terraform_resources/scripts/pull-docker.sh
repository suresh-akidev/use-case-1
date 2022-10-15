aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 157673692367.dkr.ecr.us-east-1.amazonaws.com
docker tag thala-app:latest 157673692367.dkr.ecr.us-east-1.amazonaws.com/app-repo:latest
docker push 157673692367.dkr.ecr.us-east-1.amazonaws.com/app-repo:latest