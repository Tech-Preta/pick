# Comandos extras para a administração de um cluster Kubernetes

Os comandos abaixo são úteis para a administração de um cluster Kubernetes.

```bash

# Listar os nodes do cluster
kubectl get nodes -o wide

# Listar os pods de do namespace kube-system
kubectl get pods -n kube-system

#  Listar os pods de do namespace kube-system ordenados pelo nome do node
kubectl get pods -n kube-system -o wide

# Listar os pods de do namespace kube-system ordenados pela data de criação
kubectl get pods -n kube-system -o wide --sort-by=.spec.nodeName

# Listar os pods de do namespace kube-system ordenados pela data de criação e filtrando apenas os pods em execução
kubectl get pods -n kube-system -o wide --sort-by=.metadata.creationTimestamp -A --field-selector=status.phase=Running

# Listar os pods de do namespace kube-system ordenados pela data de criação e filtrando apenas os pods em execução do kube-proxy
kubectl get pods -n kube-system -o wide --sort-by=.metadata.creationTimestamp -A --field-selector=status.phase=Running | grep -i kube-proxy

# Listar os pods de do namespace kube-system ordenados pela data de criação e filtrando apenas os pods em execução do coredns
kubectl get pods -n kube-system -o wide --sort-by=.metadata.creationTimestamp -A --field-selector=status.phase=Running | grep -i coredns

# Listar os pods de do namespace kube-system ordenados pela data de criação e filtrando apenas os pods em execução do kube-scheduler
kubectl get pods -n kube-system -o wide --sort-by=.metadata.creationTimestamp -A --field-selector=status.phase=Running | grep -i kube-scheduler

# Listar os pods de do namespace kube-system ordenados pela data de criação e filtrando apenas os pods em execução do kube-controller-manager
kubectl get pods -n kube-system -o wide --sort-by=.metadata.creationTimestamp -A --field-selector=status.phase=Running | grep -i kube-controller-manager

# Listar os pods de do namespace kube-system ordenados pela data de criação e filtrando apenas os pods em execução do etcd
kubectl get pods -n kube-system -o wide --sort-by=.metadata.creationTimestamp -A --field-selector=status.phase=Running | grep -i etcd

# Listar os pods de do namespace kube-system ordenados pela data de criação e filtrando apenas os pods em execução do kube-apiserver
kubectl get pods -n kube-system -o wide --sort-by=.metadata.creationTimestamp -A --field-selector=status.phase=Running | grep -i kube-apiserver
```

Por default o nó control-plane não executa pods de aplicação, apenas os pods do sistema. Para verificar se o nó master está com taints, execute o comando abaixo:

```bash
kubectl describe nodes <node-name> | grep -i taints
```

Para remover o taint do nó master, execute o comando abaixo:

```bash
kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane:NoSchedule
```
