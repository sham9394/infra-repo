🛠️ DevOps Monitoring Setup — Kubernetes + Jenkins + Docker Compose

This guide provides a complete monitoring stack for:
Kubernetes Nodes
Kubernetes Pods (via cAdvisor)
Jenkins Master
Jenkins Agents
Master CPU/RAM/Storage
Grafana Dashboards
Everything runs via Docker Compose on the Kubernetes Master Node.

🔐 1. Fix Jenkins SSH HostKey Checking

Create the SSH config file:
vi /var/lib/jenkins/.ssh/config

Insert:
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null

Restart Jenkins:
sudo systemctl restart jenkins

📊 2. Full Monitoring Setup (Prometheus + Grafana + Node Exporter + cAdvisor)
✔ Runs only on the Kubernetes Master
✔ Provides full cluster + Jenkins observability
📁 STEP 1 — Create monitoring folder

Run on Kubernetes Master Node:

mkdir -p /opt/monitoring
cd /opt/monitoring

📄 STEP 2 — Create Prometheus Config
vi /opt/monitoring/prometheus.yml

(Add your scrape configs inside)

📦 STEP 3 — Create Docker Compose File
vi /opt/monitoring/docker-compose.yml

This should include at minimum:
Prometheus
Grafana
cAdvisor
Node Exporter
kube-state-metrics (optional but recommended)

▶ STEP 4 — Start Monitoring Stack
cd /opt/monitoring
docker-compose up -d
docker-compose ps

🌐 STEP 5 — Open Grafana
http://<K8S_MASTER_IP>:3000

Example:
http://13.203.226.128:3000

Login (default):
user: admin
pass: admin

📦 STEP 6 — Install Node Exporter on Jenkins Master & Agents
./install-nodeexpoter.sh

📊 STEP 7 — Import Grafana Dashboards

Open Grafana →
Go to:
Create → Import
Choose one of:
Upload JSON file
OR open your dashboard file and copy/paste the whole JSON

Set datasource to:
Prometheus

Dashboard will appear as:

Unified - K8s + Jenkins Overview
📈 What the Dashboard Includes
Kubernetes
Node CPU / Memory / Load
Disk usage
Pod restarts
Pod CPU / Memory (via cAdvisor)
Deployment replica availability (via kube-state-metrics)
Jenkins
Build queue size
Running executors
Build status metrics
(Requires Jenkins Prometheus Plugin)

Features
Dropdown filter: nodename
Auto refresh every 10s (editable)

🛠️ Troubleshooting (Common Issues)
❌ Panels are blank

✔ Ensure the Grafana data source is exactly named Prometheus
✔ Check Prometheus targets:

http://<MASTER_IP>:9090/targets

❌ Jenkins metrics missing

✔ Install the Prometheus Metrics Plugin in Jenkins
✔ Enable endpoint:

http://<jenkins-url>/prometheus

🎉 Final Result

With this simplified setup you now have:
✔ Full Kubernetes Monitoring
✔ Jenkins Master Monitoring
✔ Jenkins Agent Monitoring
✔ Unified Grafana Dashboards
✔ Runs anywhere using Docker Compose
✔ Zero complex Helm charts needed
