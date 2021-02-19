# Kind Dev Cluster on Codespaces

This will setup a Kubernetes developer cluster using `Kind` and `GitHub Codespaces`

![License](https://img.shields.io/badge/license-MIT-green.svg)

## Setup

### Open with Codespaces

- Click the `Code` button on this repo
- Click `Open with Codespaces`
- Click `New Codespace`

![Create Codespace](./images/OpenWithCodespaces.jpg)

### Build and Deploy Cluster

- From the Codespaces terminal
  - `make all`

![Running Codespace](./images/RunningCodespace.jpg)

### View Grafana Dashboard

> Some popup blockers block the new browser tab
>
> If you get a gateway error, just hit refresh - it will clear once the port-forward is ready
>
> You will need the information in the next section to login / use Grafana

- Once `make all` completes successfully
  - Click on the `ports` tab of the terminal window
  - Click on the `world icon` on the Grafana port (32000)
  - This will open Grafana in a new browser tab

![Codespace Ports](./images/CodespacePorts.jpg)

### Login to Grafana

- From the Grafana dashboard
  - admin
  - Ngsa512

- Click on `Home` at the top of the page
- From the dashboards page, click on `NGSA`

![Grafana](./images/Grafana.jpg)

### Build and deploy a local version of LodeRunner

- Leave the Grafan tab open
- Switch back to your Codespaces tab

```bash

# from Codespaces terminal

# check the current verion of LodeRunner
http localhost:30088/version

# make and deploy a local version of LodeRunner to k8s
make loderunner

# wait for loderunner to start
kubectl get po

# check the new verion of LodeRunner
http localhost:30088/version

```

### Run a local test

```bash
# from Codespaces terminal

# change to the loderunner repo
cd ../loderunner

# run a baseline test
# this test will generate errors in the grafana dashboard by design

dotnet run -- -s http://localhost:30080 -f baseline.json

```

- Switch to the Grafana brower tab
- The test will generate 400 / 404 results
- The requests metric will go from green to yellow to red as load increases
  - It may skip yellow
- As the test completes
  - The metric will go back to green (1.0)
  - The request graph will return to normal

### Service endpoints

> All endpoints are usable in your browser via clicking on the `Ports (4)` tab

```bash

# Prometheus
http localhost:30000

# Grafana
http localhost:32000

# LodeRunner
# note the / url will fail by design
http localhost:30088/version
http localhost:30088/metrics

# NGSA-App

# swagger
http localhost:30080

# version, metrics health
http localhost:30080/version
http localhost:30080/metrics
http localhost:30080/healthz
http localhost:30080/healthz/ietf

# actors API
http localhost:30080/api/actors
http localhost:30080/api/actors/nm0000206
http localhost:30080/api/actors?q=keanu

# genres api
http localhost:30080/api/genres

# movies api
http localhost:30080/api/movies
http localhost:30080/api/movies/tt0133093
http localhost:30080/api/movies?q=matrix
http localhost:30080/api/movies?genre=action
http localhost:30080/api/movies?year=1999
http localhost:30080/api/movies?rating=8.0

```
