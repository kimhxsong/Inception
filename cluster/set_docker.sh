brew install docker-machine docker docker-compose

mkdir -p ~/goinfre/.docker
ln -sf ~/goinfre/.docker ~/.docker

docker-machine kill dev
docker-machine rm dev
docker-machine create --driver virtualbox dev

echo $(eval docker-machine env dev) > ~/.zprofile
