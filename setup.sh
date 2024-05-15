#!/bin/bash

repositories=(
    https://github.com/megafontj/api-gateway.git
    https://github.com/megafontj/tweets-service.git
    https://github.com/megafontj/account-service.git
    https://github.com/megafontj/auth-service.git
)

for repo in "${repositories[@]}"; do
  service_name=$(basename "$repo" .git)
  if [ -d "../$service_name" ]; then
    echo "$service_name exists"
  else
    git clone $repo ../${service_name}
  fi
done

cd ../

for repo in "${repositories[@]}"; do
  service_name=$(basename "$repo" .git)
  cd $service_name
  cp .env.example .env
  cp src/.env.example src/.env
  docker compose up --build -d
  docker compose exec app composer install
  docker compose exec app npm install
  docker compose exec app npm build
  ./artisan migrate
  ./artisan key:generate
  ./artisan optimize
  chmod 777 -R src/storage
  cd ..
  pwd
done