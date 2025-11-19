Create config file 
vi /var/lib/jenkins/.ssh/config

insert

Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null

sudo systemctl restart jenkins

----------MONITORING...................
1. Full Docker-Compose Monitoring Setup (Beginner Version)

This will run on Kubernetes Master only and monitor:
Kubernetes Nodes
Kubernetes Pods (via cAdvisor)
Jenkins Master
Jenkins Agents
Master CPU/RAM/Storage
Dashboards in Grafana

STEP 1 — Create monitoring folder

Run on Kubernetes Master Node:
mkdir -p /opt/monitoring
cd /opt/monitoring

STEP 2 — Create Prometheus Config
vi /opt/monitoring/prometheus.yml

STEP 3 — Create docker-compose.yml
vi /opt/monitoring/docker-compose.yml

STEP 4 — Start Monitoring Stack

cd /opt/monitoring
docker-compose up -d
docker-compose ps

STEP 5 — Open Grafana

http://<K8S_MASTER_IP>:3000

STEP 6 — Install node_exporter on Jenkins Master & Agent
./install-nodeexpoter.sh

STEP 7 — Import Grafana Dashboards

vi Unified-grafana-dashboard·json
Next steps — exactly what to do (copy/paste):
On your machine (or Kubernetes master) open Grafana: http://13.203.226.128:3000 and log in.
In Grafana go to ⚙️ Create → Import.
Choose Upload JSON file and select the dashboard file from the canvas (it's already in the document I created). If you prefer, open the canvas document, copy the entire JSON and paste it into the Import JSON box.
When Grafana asks, set the Prometheus data source (it should already match the datasource name Prometheus).
Import. The dashboard titled Unified - K8s + Jenkins Overview will appear.
What the dashboard contains:
Node CPU, Memory, Load, Disk usage (by nodename)
Pod restarts & container CPU/memory (cAdvisor)
Deployment replica availability (kube-state-metrics)
Jenkins builds, queue size and executors (requires Jenkins Prometheus plugin)
A node variable (nodename) to filter panels quickly
Refresh set to 10s (adjust if needed)
If anything doesn't display (blank panels), common fixes:
Make sure Grafana's Prometheus data source is named Prometheus. If it has a different name, edit the dashboard's data source or change the Grafana data source name.
Ensure Prometheus is actually scraping the targets (open Prometheus UI http://13.203.226.128:9090/targets).
Install Jenkins Prometheus plugin and enable /prometheus if Jenkins panels show no data.

🎉 FINAL RESULT
With this super-simple Docker Compose setup, you now have:

✔ Full Kubernetes Monitoring
✔ Jenkins Master Monitoring
✔ Jenkins Agent Monitoring
✔ All dashboards ready
✔ Single Grafana UI
