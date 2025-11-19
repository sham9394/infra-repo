pipeline {
    agent any

    environment {
        IMAGE = "sham9394/cityzen"
        IMAGE_TAG = "${BUILD_NUMBER}"
        INFRA_REPO = "https://github.com/sham9394/infra-repo.git"
        CODE_REPO = "https://github.com/sham9394/code-repo.git"
        K8S_NAMESPACE = "default"
        DEPLOYMENT_FILE = "/home/root/workspace/Pipeline/K8s/deployment.yml"
    }

    stages {

        stage('check Infrastructure..') {
            agent { label 'Node' }
            steps {
                script {
                    def status = sh(script: "kubectl cluster-info >/dev/null 2>&1", returnStatus: true)
                    if (status != 0) {
                        echo "Kubernetes cluster NOT found. Infrastructure setup will run........."
                    } else {
                        echo "Kubernetes cluster already exists. Skipping infra setup........."
                    }
                    env.CLUSTER_STATUS = "${status}"
                    echo "DEBUG: Saved CLUSTER_STATUS=${env.CLUSTER_STATUS}"
                }
            }
        }

        stage('Setup Infrastructure..') {
            when {
                expression { env.CLUSTER_STATUS != "0" }
            }
            steps {
                script {
                    echo "🚀 Running Ansible playbook to create Kubernetes cluster........."
                    git url: "${INFRA_REPO}", branch: 'main'
                    sh '''
                        cd "$WORKSPACE/Ansible"
                        ansible-playbook -i inventory.ini cleanup-k8s.yml
                        ansible-playbook -i inventory.ini k8s-clusters-setup.yml
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            agent { label 'Node' }
            steps {
                echo "Pulling code-repo and preparing Docker........."
                git url: "${CODE_REPO}", branch: 'main'
                sh '''
                    if ! command -v docker >/dev/null; then
                        sudo apt-get update -y
                        sudo apt-get install -y docker.io
                        sudo systemctl enable --now docker
                    fi
                '''
                sh '''
                    echo "🚀 Building Docker image ${IMAGE}:${IMAGE_TAG}"
                    cd frontend
                    docker build -t ${IMAGE}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Trivy Scan') {
            agent { label 'Node' }
            steps {
                sh '''
                echo "Scanning local image: ${IMAGE}:${IMAGE_TAG}........"
                C=$WORKSPACE/trivy-cache
                mkdir -p $C

                # Download DB
                docker run --rm \
                    -v $C:/root/.cache/ \
                    aquasec/trivy image --download-db-only

                # JSON Output
                docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v $C:/root/.cache/ \
                    -v $WORKSPACE:/w \
                    aquasec/trivy image \
                    --format json -o /w/trivy.json \
                    ${IMAGE}:${IMAGE_TAG}

                # Fail pipeline on HIGH/CRITICAL
                docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v $C:/root/.cache/ \
                    aquasec/trivy image \
                    --exit-code 1 --severity HIGH,CRITICAL \
                    ${IMAGE}:${IMAGE_TAG}
                '''
            }
            post {
                always { archiveArtifacts artifacts: 'trivy.*', fingerprint: true }
            }
        }

        stage('Push Docker Image') {
            agent { label 'Node' }
            steps {
                echo "Pushing Docker image and tagging as latest......."
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_PASSWORD'
                    )
                ]) {
                    sh """
                        echo \$DOCKERHUB_PASSWORD | docker login -u \$DOCKERHUB_USERNAME --password-stdin
                        docker push ${IMAGE}:${IMAGE_TAG}
                        docker tag ${IMAGE}:${IMAGE_TAG} ${IMAGE}:latest
                        docker push ${IMAGE}:latest
                        docker rmi ${IMAGE}:${IMAGE_TAG} || true
                        docker rmi ${IMAGE}:latest || true
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            agent { label 'Node' }
            steps {
                echo "Updating deployment.yml with latest Docker image........"
                sh """
                    sed -i 's|image:.*|image: ${IMAGE}:${IMAGE_TAG}|' ${DEPLOYMENT_FILE}
                    kubectl apply -f ${DEPLOYMENT_FILE} -n ${K8S_NAMESPACE}
                    kubectl rollout status deployment/cityzen-frontend -n ${K8S_NAMESPACE}
                """
            }
        }

    }
    
    post {
        success {
            echo "Pipeline completed successfully.........!"
        }
        failure {
            echo "Pipeline failed. Check logs!........."
        }
    }
}
