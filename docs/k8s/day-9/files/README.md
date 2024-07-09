# Criando um cluster eks com o eksctl

Para criar um cluster EKS com o eksctl, você precisa ter o eksctl instalado, realize a instalação com o comando abaixo:

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

Iremos precisar do AWS CLI instalado e configurado em nossa máquina. Para instalar o AWS CLI, use o comando abaixo:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Agora exporte as variáveis de ambiente com suas credenciais da AWS:

```bash
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
export AWS_DEFAULT_REGION=your_region
```

Para criar um cluster EKS, execute o comando abaixo:

```bash
eksctl create cluster --name=nataliagranato --nodes=2 --node-type=t3.medium
```

Outra opção é criar um arquivo de configuração para o eksctl, como o exemplo abaixo:

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: nataliagranato
  region: us-east-1
  version: "1.29"

availabilityZones: ["us-east-1a", "us-east-1b", "us-east-1c"]

vpc:
  cidr: 172.20.0.0/16
  clusterEndpoints:
    publicAccess: true
    privateAccess: true

iam:
  withOIDC: true
  serviceAccounts:
  - metadata:
      name: s3-fullaccess
    attachPolicyARNs:
    - "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  - metadata:
      name: aws-load-balancer-controller
      namespace: kube-system
    wellKnownPolicies:
      awsLoadBalancerController: true
  - metadata:
      name: external-dns
      namespace: kube-system
    wellKnownPolicies:
      externalDNS: true
  - metadata:
      name: cert-manager
      namespace: cert-manager
    wellKnownPolicies:
      certManager: true
  - metadata:
      name: cluster-autoscaler
      namespace: kube-system
    wellKnownPolicies:
      autoScaler: true
```

Para criar o cluster com o arquivo de configuração, execute o comando abaixo:

```bash
eksctl create cluster -f cluster.yaml
```

Crie um nodegroup com o comando abaixo:

```bash
eksctl create nodegroup --cluster=nataliagranato --region=us-east-1 --name=ng-1 --node-type=t3.medium --nodes=2 --nodes-min=2 --nodes-max=4
```

ou com o arquivo de configuração:

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: nataliagranato
  region: us-east-1
  version: "1.29"

managedNodeGroups:
- name: ng-ondemand
  instanceTypes: ["m6a.xlarge"]
  spot: false
  privateNetworking: true
  minSize: 1
  maxSize: 1
  desiredCapacity: 1
  volumeSize: 50
  volumeType: gp3
  updateConfig:
    maxUnavailablePercentage: 30
  availabilityZones: ["us-east-1a"]
  ssh:
    allow: false
  labels:
    node_group: ng-ondemand
  tags:
    nodegroup-role: ng-ondemand
    k8s.io/cluster-autoscaler/enabled: "true"
    k8s.io/cluster-autoscaler/cco-hml: "owned"

  iam:
    withAddonPolicies:
      externalDNS: true
      certManager: true
      imageBuilder: true
      albIngress: true
      autoScaler: true
      ebs: true
      efs: true
```

Para criar o nodegroup com o arquivo de configuração, execute o comando abaixo:

```bash
eksctl create nodegroup -f nodegroup.yaml
```

Para deletar o cluster, execute o comando abaixo:

```bash
eksctl delete cluster --name=nataliagranato
```

## Prometheus Operator e o Kube-Prometheus

O Prometheus Operator é um projeto que facilita a configuração e o gerenciamento do Prometheus e de seus componentes relacionados. O Kube-Prometheus é um conjunto de arquivos de configuração e scripts que facilitam a instalação do Prometheus Operator e de seus componentes relacionados em um cluster Kubernetes.

## Instalando o Kube-Prometheus

Realize o clone do repositório do Kube-Prometheus:

```bash
git clone https://github.com/prometheus-operator/kube-prometheus
cd kube-prometheus
kubectl create -f manifests/setup
kubectl create -f manifests/
```

Caso enfrente o problema `spec: failed to generate spec: path "/sys" is mounted on "/sys" but it is not a shared or slave mount` no daemonset node-exporter, use o manifesto abaixo para corrigir:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app.kubernetes.io/component: exporter
    app.kubernetes.io/name: node-exporter
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 1.8.1
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/component: exporter
      app.kubernetes.io/name: node-exporter
      app.kubernetes.io/part-of: kube-prometheus
  template:
    metadata:
      annotations:
        kubectl.kubernetes.io/default-container: node-exporter
      labels:
        app.kubernetes.io/component: exporter
        app.kubernetes.io/name: node-exporter
        app.kubernetes.io/part-of: kube-prometheus
        app.kubernetes.io/version: 1.8.1
    spec:
      automountServiceAccountToken: true
      containers:
      - args:
        - --web.listen-address=127.0.0.1:9100
        - --path.sysfs=/host/sys
        - --path.rootfs=/host/root
        - --path.udev.data=/host/root/run/udev/data
        - --no-collector.wifi
        - --no-collector.hwmon
        - --no-collector.btrfs
        - --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run/k3s/containerd/.+|var/lib/docker/.+|var/lib/kubelet/pods/.+)($|/)
        - --collector.netclass.ignored-devices=^(veth.*|[a-f0-9]{15})$
        - --collector.netdev.device-exclude=^(veth.*|[a-f0-9]{15})$
        image: quay.io/prometheus/node-exporter:v1.8.1
        name: node-exporter
        resources:
          limits:
            cpu: 250m
            memory: 180Mi
          requests:
            cpu: 102m
            memory: 180Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - SYS_TIME
            drop:
            - ALL
          readOnlyRootFilesystem: true
        volumeMounts:
        - mountPath: /host/sys
          name: sys
          readOnly: true
        - mountPath: /host/root
          mountPropagation: HostToContainer
          name: root
          readOnly: true
      - args:
        - --secure-listen-address=[$(IP)]:9100
        - --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
        - --upstream=http://127.0.0.1:9100/
        env:
        - name: IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        image: quay.io/brancz/kube-rbac-proxy:v0.18.0
        name: kube-rbac-proxy
        ports:
        - containerPort: 9100
          hostPort: 9100
          name: https
        resources:
          limits:
            cpu: 20m
            memory: 40Mi
          requests:
            cpu: 10m
            memory: 20Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsGroup: 65532
          runAsNonRoot: true
          runAsUser: 65532
          seccompProfile:
            type: RuntimeDefault
      hostNetwork: true
      hostPID: true
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      securityContext:
        runAsGroup: 65534
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: node-exporter
      tolerations:
      - operator: Exists
      volumes:
      - hostPath:
          path: /sys
        name: sys
      - hostPath:
          path: /
        name: root
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 10%
    type: RollingUpdate
```

A `mountPropagation: HostToContainer` foi retirada do volume `/sys` e mantida no volume `/root`.

## Acessando o Grafana e os Dashboards

Para acessar o Grafana utilize o `kubectl port-forward`:

```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

Acesse o Grafana em `http://localhost:3000` com o usuário `admin` e a senha `admin`. Será solicitado a troca de senha.

### Acessando o Prometheus e o Alertmanager

Para acessar o Prometheus e o Alertmanager, utilize o `kubectl port-forward`:

```bash
kubectl port-forward -n monitoring svc/prometheus-k8s 9090:9090
kubectl port-forward -n monitoring svc/alertmanager-main 9093:9093
```

### O que são os monitores do Prometheus?

Os monitores do Prometheus são arquivos de configuração que definem o que e como coletar métricas de um serviço ou aplicação. Eles são escritos em uma linguagem de consulta chamada PromQL.

### O que são os alertas do Alertmanager?

A principal função do Alertmanager é receber alertas do Prometheus e enviá-los para os destinatários corretos. Os alertas são definidos em arquivos de configuração chamados de regras de alerta. As regras de alerta são escritas em uma linguagem de consulta chamada PromQL. É possível definir regras de alerta para qualquer métrica coletada pelo Prometheus e integrar com diversos serviços de notificação.
