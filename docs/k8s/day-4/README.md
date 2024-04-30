## O que é um ReplicaSet?

Um ReplicaSet é um objeto do Kubernetes que garante que um número especificado de réplicas de um pod esteja em execução a qualquer momento. Ele é frequentemente usado para garantir a disponibilidade e a redundância dos pods.

## O Deployment e o ReplicaSet

Um Deployment é um objeto do Kubernetes que fornece atualizações declarativas para Pods e ReplicaSets. Você descreve o estado desejado em um objeto Deployment e o controlador de Deployment muda o estado atual para o estado desejado em um ritmo controlado para o usuário.

## O que é um DaemonSet?

Um DaemonSet garante que todos (ou alguns) os nós executem uma cópia de um Pod. À medida que os nós são adicionados ao cluster, os Pods são adicionados a eles. À medida que os nós são removidos do cluster, esses Pods são coletados como lixo.

## Criando um DaemonSet

Para criar um DaemonSet, você precisa definir um arquivo YAML com as especificações do DaemonSet e usar o comando `kubectl apply -f your-daemonset.yaml` para criar o DaemonSet. Um exemplo:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      name: nginx
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:26
        ports:
        - containerPort: 80
```

O exemplo acima cria um DaemonSet chamado `nginx-daemonset` que garante que todos os nós do cluster tenham um pod chamado `nginx` em execução.

## O que são as probes no Kubernetes?

As probes são mecanismos usados pelo Kubernetes para determinar quando reiniciar um contêiner. Kubernetes usa três tipos de probes: Readiness, Liveness e Startup.

## Exemplos de probes no Kubernetes

As probes no Kubernetes são usadas para verificar o estado de um Pod e são divididas em três tipos: Liveness, Readiness e Startup.

- **Liveness Probe**: Esta sonda é usada para saber quando reiniciar um contêiner. Se a liveness probe falhar, o Kubernetes irá matar o contêiner e o contêiner será recriado.

- **Readiness Probe**: Esta sonda é usada para decidir quando o contêiner está pronto para aceitar tráfego. Se a readiness probe falhar, o Kubernetes irá parar de enviar tráfego para o Pod até que a sonda tenha sucesso.

- **Startup Probe**: Esta sonda é usada para saber quando um contêiner começou com sucesso. Ela é usada para evitar que um contêiner seja morto pelo Kubernetes antes que esteja pronto para servir o tráfego.

As probes podem ser configuradas de três maneiras:

- **httpGet**: Faz uma solicitação HTTP para o contêiner.

- **tcpSocket**: Faz uma solicitação TCP para o contêiner.

- **exec**: Executa um comando no contêiner.

Aqui estão alguns exemplos de como você pode definir probes em seu arquivo de configuração do Kubernetes:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20

readinessProbe:
  exec:
    command:
    - cat
    - /app/is_ready
  initialDelaySeconds: 5
  periodSeconds: 5

startupProbe:
  httpGet:
    path: /health
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```
