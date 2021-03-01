# Kind Dev Cluster on Codespaces

This will setup a Kubernetes developer cluster using `Kind` and `GitHub Codespaces`

![License](https://img.shields.io/badge/license-MIT-green.svg)

## Open with Codespaces

- Click the `Code` button on this repo
- Click `Open with Codespaces`
- Click `New Codespace`

![Create Codespace](./images/OpenWithCodespaces.jpg)

## Open Workspace

- Click on the `hamburger` menu in upper left
- Choose `File`
- Choose `Open workspace`
- Click on `..` in selector
- Click on `akdc.code-workspace`

## Build and Deploy Cluster

- From the Codespaces terminal
  - `make all`

![Running Codespace](./images/RunningCodespace.jpg)

## Validate Deployment

Output from `make all` should resemble this

```text

default      fluentb                                   1/1   Running   0   31s
default      loderunner                                1/1   Running   0   31s
default      ngsa-memory                               1/1   Running   0   33s
monitoring   grafana-64f7dbcf96-cfmtd                  1/1   Running   0   32s
monitoring   prometheus-deployment-67cbf97f84-tjxm7    1/1   Running   0   32s

# curl all of the endpoints
{ "apiVersion": "1.0", "appVersion": "0.1.1-0210-0338", "language": "C#" }

0.1.1-0210-0537

<a href="/graph">Found</a>.

<a href="/login">Found</a>.

```

## Validate deployment with k9s

- From the Codespace terminal window, start `k9s`
  - Type `k9s` and press enter
  - Press `0` to select all namespaces
  - Wait for all pods to be in the `Running` state (look for the `STATUS` column)
  - Use the arrow key to select `nsga-memory` then press the `l` key to view logs from the pod
  - To go back, press the `esc` key
  - To view other deployed resources - press `shift + :` followed by the deployment type (e.g. `secret`, `services`, `deployment`, etc).
  - To exit - `:q <enter>`

![k9s](./images/k9s.jpg)

## Service endpoints

- All endpoints are usable in your browser via clicking on the `Ports (4)` tab
  - Select the `open in browser icon` on the far right
- Some popup blockers block the new browser tab
- If you get a gateway error, just hit refresh - it will clear once the port-forward is ready

```bash

# check endpoints
make check

```

### Other interesting endpoints

Open [curl.http](./curl.http)

> [curl.http](./curl.http) is used in conjuction with the Visual Studio Code [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) extension.
>
> When you open [curl.http](./curl.http), you should see a clickable `Send Request` text above each of the URLs

![REST Client example](./images/RESTClient.png)

Clicking on `Send Request` should open a new panel in Visual Studio Code with the response from that request like so:

![REST Client example response](./images/RESTClientResponse.png)

## Launch Grafana Dashboard

- Grafana login info
  - admin
  - Ngsa512

- Once `make all` completes successfully
  - Click on the `ports` tab of the terminal window
  - Click on the `open in browser icon` on the Grafana port (32000)
  - This will open Grafana in a new browser tab

![Codespace Ports](./images/CodespacePorts.jpg)

## View Grafana Dashboard

- Click on `Home` at the top of the page
- From the dashboards page, click on `NGSA`

![Grafana](./images/Grafana.jpg)

## Run a load test

```bash

# from Codespaces terminal
make load-test

```

- Switch to the Grafana brower tab
- The test will generate 400 / 404 results
- The requests metric will go from green to yellow to red as load increases
  - It may skip yellow
- As the test completes
  - The metric will go back to green (1.0)
  - The request graph will return to normal

![Load Test](./images/LoadTest.jpg)

## View Prometheus Dashboard

- Click on the `ports` tab of the terminal window
- Click on the `open in browser icon` on the Prometheus port (30000)
- This will open Prometheus in a new browser tab

- From the Prometheus tab
  - Begin typing NgsaAppDuration_bucket in the `Expression` search
  - Click `Execute`
  - This will display the `histogram` that Grafana uses for the charts

## View Fluent Bit Logs

- Start `k9s` from the Codespace terminal
- Select `fluentb` and press `enter`
- Press `enter` again to see the logs
- Press `s` to Toggle AutoScroll
- Press `w` to Toggle Wrap
- Review logs that will be sent to Log Analytics when configured

## Build and deploy a local version of LodeRunner

- Switch back to your Codespaces tab

```bash

# from Codespaces terminal

# make and deploy a local version of LodeRunner to k8s
make loderunner

```

## Build and deploy a local version of ngsa-memory

- Switch back to your Codespaces tab

```bash

# from Codespaces terminal

# make and deploy a local version of ngsa-memory to k8s
make app

```

## Next Steps

> [Makefile](./Makefile) is a good place to start exploring

## FAQ

**Question:** Why don't we use helm to deploy Kubernetes manifests?

**Answer:** The purpose of this repository is to get developers up and running, with all dependencies install and deployed, so they can focus on writing code. The target audience for this repository is the app developers who do not necessary care about how their app is deployed.

Leaving the manifests as is rather than converting them to helm has the added benefit of readability so if a developer did want to see how their app is deployed or if they need to make modifications to the deployment, it is a lot easier to do so.

In saying that, we do have helm installed inside the `.devcontainer` to make it easy to deploy additional dependencies to the cluster in future.
