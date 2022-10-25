docker build -t $1 ../.
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $2/$3
docker tag $1 $2/$3:$1
docker push $2/$3:$1
