# Kubernetes e Pods

## O que é um Pod no Kubernetes?

Um Pod é a menor e mais simples unidade no modelo de objeto do Kubernetes. Um Pod representa um processo único em um cluster e pode conter um ou mais contêineres. Os contêineres dentro de um Pod compartilham o mesmo contexto de rede e podem se comunicar entre si usando `localhost`.

## Comandos Básicos do kubectl

### kubectl get pods

Este comando lista todos os Pods que estão atualmente em execução no cluster ou no namespace especificado.

Exemplo de uso:

```bash
kubectl get pods
```

### kubectl describe pod

Este comando mostra detalhes sobre um Pod específico.

Exemplo de uso:

```bash
kubectl describe pods <nome_do_pod>
```

### Utilizando kubectl attach e kubectl exec

**kubectl attach**
Este comando permite que você execute um comando específico dentro de um contêiner em um Pod.

Exemplo de uso:

```bash
kubectl exec <nome_do_pod> -- <comando>
```

**kubectl exec**
Este comando permite que você execute um comando específico dentro de um contêiner em um Pod.

Exemplo de uso:

```bash
kubectl exec <nome_do_pod> -- <comando>
```

## Criando um Pod com Multi-contêineres

Aqui está um exemplo de um manifesto para criar um Pod com vários contêineres:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: meu-pod-multicontainer
spec:
  containers:
  - name: nginx-container
    image: nginx
  - name: busybox-container
    image: busybox
    command: ['sh', '-c', 'echo Hello, world!']
```

Para criar o Pod, salve o manifesto acima em um arquivo chamado meu-pod.yaml e execute o seguinte comando:

```
kubectl apply -f meu-pod.yaml
```

## Limitando Recursos de CPU e memória de um Pod

Aqui está um exemplo de um manifesto para criar um Pod com limites de recursos de CPU e memória:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: meu-pod-multicontainer
spec:
  containers:
  - name: nginx-container
    image: nginx
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: busybox-container
    image: busybox
    command: ['sh', '-c', 'echo Hello, world! && sleep infinity']

```

# Requests e Limits no Kubernetes

`Requests` e `limits` são conceitos fundamentais no Kubernetes que ajudam a gerenciar o uso de recursos em um cluster.

## Requests

`Requests` são o que o contêiner está garantido para ter como recurso. Quando um contêiner é criado, o Kubernetes reserva a quantidade de recurso especificada na solicitação para o contêiner. Isso é usado pelo agendador do Kubernetes para decidir em qual nó colocar o Pod. Se um nó não tem recursos suficientes disponíveis para atender à solicitação do Pod, o Pod não será agendado para aquele nó.

## Limits

`Limits`, por outro lado, são a quantidade máxima de recurso que um contêiner pode usar. Se um contêiner excede o limite de um recurso, ele pode ser encerrado ou ter sua CPU limitada, dependendo do recurso e das configurações do cluster.

A importância de definir `requests` e `limits` adequados é dupla:

1. **Eficiência de recursos**: Ao definir `requests` e `limits`, você pode garantir que seus Pods estão usando os recursos de maneira eficiente, sem consumir mais do que o necessário.

2. **Isolamento de recursos**: `requests` e `limits` também ajudam a evitar que um Pod monopolize todos os recursos em um nó, o que pode afetar outros Pods no mesmo nó.

Portanto, é uma boa prática definir `requests` e `limits` para seus contêineres para garantir o uso eficiente dos recursos e a coexistência harmoniosa de múltiplos Pods em um único nó.
