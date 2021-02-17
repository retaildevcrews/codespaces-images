# akdc-kind

Post setup

```bash

export KIND_ID=$(docker ps | grep kindest/node | cut -f 1 -d ' ')

docker exec $KIND_ID mkdir -p /prometheus
docker exec $KIND_ID chown -R 65534:65534 /prometheus

docker exec $KIND_ID mkdir -p /grafana
docker cp grafana.db ${KIND_ID}:/grafana
docker exec $KIND_ID chown -R 472:472 /grafana

```
