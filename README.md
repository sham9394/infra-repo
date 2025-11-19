Create config file 
vi /var/lib/jenkins/.ssh/config

insert

Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null

sudo systemctl restart jenkins
