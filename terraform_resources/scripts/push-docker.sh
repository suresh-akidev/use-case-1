docker build --platform linux/amd64 -t $1 ../.
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $2/$3
docker tag $1 $2/$3:$1
docker push $2/$3:$1
