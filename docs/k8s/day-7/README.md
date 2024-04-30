# O que é um StatefulSet?

É um objeto da API de carga de trabalho usado para gerenciar aplicações stateful. Ele gerencia a implantação e escalonamento de um conjunto de Pods e fornece garantias sobre a ordenação e unicidade desses Pods. Como um Deployment, um StatefulSet gerencia Pods que são baseados em uma especificação de contêiner idêntica. No entanto, ao contrário de um Deployment, um StatefulSet mantém uma identidade fixa para cada um de seus Pods. Esses pods são criados a partir da mesma especificação, mas não são intercambiáveis: cada um tem um identificador persistente que mantém em qualquer reagendamento.

## Criando um StatefulSet

 Para criar um StatefulSet, você pode usar o comando `kubectl create ou kubectl apply`. Por exemplo, você pode criar um arquivo YAML que descreva o StatefulSet e, em seguida, aplicá-lo ao seu cluster Kubernetes. O conjunto de Pods direcionados por um StatefulSet é geralmente determinado por um seletor de rótulos.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

## Removendo um StatefulSet

Para remover um StatefulSet, você pode usar o comando `kubectl delete`, e especificar o StatefulSet por arquivo ou por nome. Por exemplo, `kubectl delete -f <file.yaml> ou kubectl delete statefulsets <statefulset-name>`.

# O que é um Service?

Um Service no Kubernetes é um método para expor uma aplicação de rede que está sendo executada como um ou mais Pods em seu cluster. Cada objeto Service define um conjunto lógico de endpoints (geralmente esses endpoints são Pods) junto com uma política sobre como tornar esses pods acessíveis.

## Tipos de Service

- **ClusterIP (padrão)**: Expõe o serviço sob um endereço IP interno no cluster.

- **NodePort**: Expõe o serviço na mesma porta em cada nó selecionado no cluster usando NAT.

- **LoadBalancer**: Cria um balanceador de carga externo no provedor de nuvem atual (se suportado) e atribui um endereço IP fixo e externo para o serviço.

- **ExternalName**: Mapeia o Service para o conteúdo do campo externalName (por exemplo, foo.bar.example.com), retornando um registro DNS do tipo CNAME com o seu valor.

## Criando um Headless Service

Um serviço headless no Kubernetes é um tipo de serviço que não tem um endereço IP de cluster atribuído. Para definir um serviço headless, definimos o campo spec.clusterIP como None em sua definição de recurso. Quando resolvemos o nome de domínio de um serviço típico, o DNS retorna um único endereço IP, que é o IP do cluster do serviço atribuído pelo plano de controle. No entanto, uma consulta DNS do nome de um serviço headless retorna uma lista de endereços IP que pertencem aos pods de backup.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None # Define o serviço como headless
  selector:
    app: nginx
```

Você também pode criar services pela linha de comando, por exemplo:

Um serviço NodePort:

```bash
kubectl expose deployment nginx --port=80 --type=NodePort
```

Um serviço LoadBalancer:

```bash
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

Um serviço ClusterIP:

```bash
kubectl expose deployment nginx --port=80 --type=ClusterIP
```

### Extra

Lembrando que é necessário ter o eksctl instalado na máquina.
Lembre-se de configurar o AWS CLI antes de criar o cluster.

Criando um cluster EKS com o eksctl:

```bash
eksctl create cluster --name nataliagranato --version 1.29 --region=us-east-1 --nodegroup-name=granato --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed
```

## Criando um service expondo um outro service

Para criar um service que exponha um outro service, você pode usar o comando `kubectl expose`. Por exemplo, você pode criar um service que exponha um outro service com o comando `kubectl expose service <service-name> --name=<new-service-name> --port=<port> --target-port=<target-port> --type=<type>`.

```bash
kubectl expose service nginx --name=nginx-service --port=80 --target-port=80 --type=NodePort
```

Isso é útil para realizar testes de conectividade entre serviços.
