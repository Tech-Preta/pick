# Kubernetes Deployments

## O que é um Deployment?

Um Deployment no Kubernetes é um objeto que pode declarar, atualizar e dimensionar aplicativos. Ele usa um Pod Template, que contém especificações para os Pods. O estado desejado é descrito no Deployment e o Controlador de Deployment muda o estado atual para o estado desejado em um ritmo controlado.

## Criando um Deployment

Você pode criar um Deployment através de um manifesto. Aqui está um exemplo de um manifesto de Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.26-bookworm
        ports:
        - containerPort: 80
```

Para criar o Deployment, você pode salvar o manifesto acima em um arquivo chamado nginx-deployment.yaml e executar o seguinte comando:

```bash
kubectl apply -f nginx-deployment.yaml
```

### Vendo os detalhes de um Deployment

Você pode ver os detalhes de um Deployment usando o comando `kubectl describe`:

```bash
kubectl describe deployment nginx-deployment
```

### Atualizando um Deployment

Você pode atualizar um Deployment alterando o manifesto e reaplicando-o com kubectl apply, ou pode usar o comando kubectl set image:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26
```

Você também pode editar o Deployment diretamente:

```bash
kubectl edit deployment nginx-deployment
```

E utilizar o comando `kubectl apply` para aplicar alterações.

```bash
kubectl apply -f nginx-deployment.yaml
```

### Estratégias de atualização de um Deployment

Existem duas estratégias de atualização para um Deployment: Recreate e Rolling Update. Por padrão, o Rolling Update é usado.

- **Recreate**: Todos os Pods existentes são mortos antes que os novos sejam criados. Aqui está um exemplo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.26
        ports:
        - containerPort: 80
```

- **Rolling Update (padrão)**: O Deployment atualiza os Pods em um ritmo controlado, matando e recriando os Pods um de cada vez. Aqui está um exemplo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.26
        ports:
        - containerPort: 80
```

### Fazendo um Rollback de um Deployment

Você pode fazer rollback para uma revisão anterior de um Deployment usando o comando `kubectl rollout undo`:

```bash
kubectl rollout undo deployment/nginx-deployment
```

### Pausando e Resumindo um Deployment

Você pode pausar um Deployment para evitar que ele faça alterações nos Pods. Para pausar um Deployment, use o comando `kubectl rollout pause`:

```bash
kubectl rollout pause deployment/nginx-deployment
```

O comando `kubectl rollout` permite que você gerencie a implantação gradual de atualizações para seus Deployments. Você pode pausar, retomar e verificar o status de um rollout, além de fazer rollback para uma revisão anterior.

### Escalando um Deployment

Você pode escalar um Deployment alterando o número de réplicas no manifesto e reaplicando-o com kubectl apply, ou usando o comando kubectl scale:

```bash
kubectl scale deployment nginx-deployment --replicas=5
```

### Verificando o ReplicaSet que o Deployment está gerenciando

Você pode verificar o ReplicaSet que um Deployment está gerenciando usando o comando `kubectl get`. Aqui está um exemplo:

```bash
kubectl get rs -l app=nginx
```

Este comando lista todos os ReplicaSets que têm a label `app=nginx`, que é a label usada no Deployment do exemplo anterior.

### Excluindo um Deployment

Você pode excluir um Deployment usando o comando kubectl delete:

```bash
kubectl delete deployment nginx-deployment
```
