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

### Validate Deployment

Once `make all` completes, validate the pods are running

```bash

# from the Codespace terminal

kubectl get pods -A

```

Output should resemble this

```text

NAMESPACE     NAME                                     READY   STATUS
default       loderunner                               1/1     Running
default       ngsa-memory                              1/1     Running


kube-system   coredns-74ff55c5b-m6s9x                  1/1     Running
kube-system   coredns-74ff55c5b-qwkb5                  1/1     Running
kube-system   etcd-k8s                                 1/1     Running
kube-system   kube-apiserver-k8s                       1/1     Running
kube-system   kube-controller-manager-k8s              1/1     Running
kube-system   kube-flannel-ds-47bll                    1/1     Running
kube-system   kube-proxy-6lvfk                         1/1     Running
kube-system   kube-scheduler-k8s                       1/1     Running


monitoring    grafana-64f7dbcf96-w966p                 1/1     Running
monitoring    prometheus-deployment-67cbf97f84-zhkm9   1/1     Running

```

### Validate deployment with k9s

- From the Codespace terminal window, start `k9s`
  - Type `k9s` and press enter

> TODO - k9s instructions / screen shot

### Service endpoints

- All endpoints are usable in your browser via clicking on the `Ports (4)` tab
  - Select the `open in browser icon` on the far right
- Some popup blockers block the new browser tab
- If you get a gateway error, just hit refresh - it will clear once the port-forward is ready

```bash

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

# LodeRunner
# note the / url will fail by design
http localhost:30088/version
http localhost:30088/metrics

# Prometheus
http localhost:30000

# Grafana
http localhost:32000

```

### View Grafana Dashboard

> You will need the information in the next section to login / use Grafana

- Once `make all` completes successfully
  - Click on the `ports` tab of the terminal window
  - Click on the `open in browser icon` on the Grafana port (32000)
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

# run a complete test
dotnet run -- -s http://localhost:30080 -f benchmark.json

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

### View Prometheus Dashboard

- Click on the `ports` tab of the terminal window
- Click on the `open in browser icon` on the Prometheus port (30000)
- This will open Prometheus in a new browser tab

- From the Prometheus tab
  - Begin typing NgsaAppDuration_bucket in the `Expression` search
  - Click `Execute`
  - This will display the `histogram` that Grafana uses for the charts
