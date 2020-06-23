< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32 > test-password

docker rm -f dqueue-mysql || echo "not deleting"
docker run --rm --net local --name dqueue-mysql -e MYSQL_ROOT_PASSWORD=$(cat test-password) mysql

docker ps
