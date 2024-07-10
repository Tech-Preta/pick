# O que é o ingress no Kubernetes?

O Ingress é uma API do Kubernetes que gerencia o acesso externo aos serviços em um cluster, tipicamente HTTP. O Ingress pode fornecer balanceamento de carga, SSL/TLS e hospedagem baseada em nome virtual.

O Ingress é um recurso de nível de aplicativo e não é fornecido por todos os controladores de nuvem. Se o seu cluster estiver em execução em um provedor de nuvem que ofereça suporte ao LoadBalancer, o controlador de nuvem criará um serviço LoadBalancer para expor seu serviço para a Internet.

## Principais componentes do Ingress e suas funcionalidades

- **Ingress Resource**: é um recurso do Kubernetes que define como o tráfego deve ser roteado para os serviços.
- **Ingress Controller**: é um controlador que implementa as regras especificadas no recurso Ingress. Ele é responsável por ler as regras do recurso Ingress e configurar o balanceador de carga ou o proxy reverso de acordo com essas regras.
- **Ingress Load Balancer**: é um balanceador de carga que distribui o tráfego entre os pods do serviço. Ele pode ser um balanceador de carga de camada 4 (TCP/UDP) ou de camada 7 (HTTP/HTTPS).
- **Ingress Rules**: são regras que definem como o tráfego deve ser roteado para os serviços. As regras podem ser baseadas em caminhos, cabeçalhos, métodos HTTP, etc.
- **Ingress Annotations**: são metadados que podem ser usados para configurar o comportamento do Ingress Controller. Eles são usados para definir configurações específicas do controlador, como redirecionamentos, regras de segurança, etc.
- **Ingress TLS**: é uma configuração que permite que o tráfego seja criptografado entre o cliente e o servidor. Ele é usado para proteger os dados em trânsito e garantir a privacidade e a integridade dos dados.
- **Ingress Class**: é uma configuração que permite que você defina qual controlador de Ingress deve ser usado para implementar as regras do Ingress. Isso é útil quando você tem vários controladores de Ingress em execução no cluster.
- **Ingress Status**: é um status que mostra o estado atual do Ingress. Ele pode ser usado para verificar se o Ingress está funcionando corretamente e se as regras estão sendo aplicadas corretamente.
- **Backend Service**: é um serviço que recebe o tráfego encaminhado pelo Ingress Controller. Ele pode ser um serviço interno ou externo, dependendo da configuração do Ingress.

## Configurando o Kind para usar o Ingress

Para usar o Ingress no Kind, você precisa instalar um controlador de Ingress no cluster. Existem vários controladores de Ingress disponíveis, como o Nginx Ingress Controller, o Traefik, o HAProxy, etc. Neste exemplo, vamos usar o Nginx Ingress Controller.

Quando você cria um cluster Kind, ele não tem suporte nativo para o Ingress. Para habilitar o suporte ao Ingress, você precisa especificar o controlador de Ingress que deseja usar ao criar o cluster. Você pode fazer isso passando a opção `--config` para o comando `kind create cluster` e especificando o arquivo de configuração do cluster.

```bash
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
```

Obtenha o kubeconfig do cluster Kind.

```bash
kind get kubeconfig --name kind > ~/.kube/kind-config-kind 
```

Configure o kubeconfig para usar o cluster Kind.

```bash
export KUBECONFIG=~/.kube/kind-config-kind
```

Agora faça a instalação do Nginx Ingress Controller no cluster Kind.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

Utilize a opção `--watch` para acompanhar a instalação do Nginx Ingress Controller.

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

Em um cluster gerenciado como o EKS, GKE ou AKS, o controlador de Ingress é exposto através de um Network Load Balancer. O comando para a instalação do Nginx Ingress Controller com o Helm é:

```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

Para uma listar os valores definidos no `values.yaml` do Nginx Ingress Controller, execute o comando abaixo:

```bash
helm show values ingress-nginx --repo https://kubernetes.github.io/ingress-nginx
```

Se preferir instalar o Nginx Ingress Controller sem o Helm, você pode usar o comando abaixo:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```

O `kubectl` possui um plugin chamado `ingress-nginx` que pode ser usado para gerenciar o Nginx Ingress Controller. Para instalar o plugin, execute o comando abaixo:

```bash
kubectl krew install ingress-nginx
```

Para verificar as suas funcionalidades utilize o comando abaixo:

```bash
kubectl ingress-nginx --help
```

Entre elas estão: `logs` do ingress, `lint` para verificar possíveis problemas, `info` para ver informações do service, `conf` para inspecionar o arquivo de configuração do Nginx, etc.

## Criando nossa aplicação de exemplo

Vamos criar uma aplicação de exemplo para testar o Ingress. Acessando o diretório `files` do repositório, você encontrará um arquivo chamado `app.yaml` e `redis.yaml` com a definição de um serviço e um deployment para a aplicação de exemplo e suas dependências.

```bash
kubectl apply -f ./files/app/app.yaml
kubectl apply -f ./files/app/redis.yaml
```

Para verificar se os recursos foram criados corretamente, execute o comando abaixo:

```bash
kubectl get all
```

Agora vamos validar se a aplicação está funcionando corretamente. Para isso, vamos utilizar o comando `port-forward` do `kubectl` para encaminhar o tráfego da porta 5000 do pod para a porta 5000 do host.

```bash
kubectl port-forward svc/giropops-senhas 5000:5000
```

## Criando uma regra de Ingress

Agora que a aplicação está funcionando corretamente, vamos criar uma regra de Ingress para acessar a aplicação de fora do cluster. Acesse o diretório `files` do repositório e aplique o arquivo `ingress.yaml`.

```yaml
apiVersion: networking.k8s.io/v1 # apiVersion do recurso
kind: Ingress # Tipo do recurso
metadata: # Metadados do recurso
  name: giropops-senhas # Nome do recurso
  annotations: # Anotações do recurso onde você pode modificar o comportamento do Ingress Controller
    nginx.ingress.kubernetes.io/rewrite-target: / # Redireciona o tráfego para a raiz do serviço
spec: # Especificação do recurso
  rules: # Regras do Ingress
  - http: # Protocolo HTTP
      paths: # Caminhos
      - path: /giropops-senhas # Caminho do serviço
        pathType: Prefix # Tipo do caminho
        backend: # Serviço de destino
          service:  # Serviço do backend
            name: giropops-senhas # Nome do serviço
            port: # Porta do serviço 
              number: 5000 # Número da porta
```

Após a aplicação verifique se o objeto `ingress` foi criado corretamente:

```bash
kubectl get ingress
```

A saída será algo como:

```bash
NAME              CLASS    HOSTS   ADDRESS     PORTS   AGE
giropops-senhas   <none>   *       localhost   80      42s
```

Para ver mais detalhes do objeto `ingress`, execute o comando abaixo:

```bash
kubectl describe ingress giropops-senhas
```

A saída será algo como:

```bash
Name:             giropops-senhas
Labels:           <none>
Namespace:        default
Address:          localhost
Ingress Class:    <none>
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /giropops-senhas   giropops-senhas:5000 (10.244.0.8:5000,10.244.0.9:5000)
Annotations:  nginx.ingress.kubernetes.io/rewrite-target: /
Events:
  Type    Reason  Age                 From                      Message
  ----    ------  ----                ----                      -------
  Normal  Sync    85s (x2 over 117s)  nginx-ingress-controller  Scheduled for sync
```

Agora você pode acessar a aplicação de fora do cluster usando o endereço `http://localhost/giropops-senhas`. Porém a aplicação está com o frontend quebrado, pois os arquivos estáticos não estão sendo servidos corretamente. Quando utilizamos a annotation `nginx.ingress.kubernetes.io/rewrite-target: /`, o Ingress Controller redireciona o tráfego para a raiz do serviço, o que faz com que os arquivos estáticos não sejam encontrados.

Se removermos a annotation `nginx.ingress.kubernetes.io/rewrite-target: /`, o redirecionamento não será feito, mas ainda assim o frontend ainda estaria quebrado porque o `path` está definido como `/giropops-senhas` e o frontend espera que os arquivos estáticos sejam servidos a partir da raiz do serviço.

O melhor cenário seria que o Ingress Controller servisse os arquivos estáticos a partir da raiz do serviço, mas mantendo o redirecionamento para o serviço correto.

## Corrigindo o problema dos arquivos estáticos

Para corrigir isso, você precisa adicionar uma regra de Ingress para servir os arquivos estáticos.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
spec:
  rules:
  - http:
      paths:
      - path: /static
        pathType: Prefix
        backend:
          service:
            name: giropops-senhas
            port:
              number: 5000
```

## Criando multiplos ingresses no mesmo Ingress Controller

Antes de mais nada iremos criar uma outra aplicação de exemplo para testar:

```bash
kubectl run nginx --image nginx --port 80
```

Vamos criar um serviço para expor a aplicação:

```bash
kubectl expose po nginx
```

Agora vamos criar um ingress para a aplicação:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: nginx.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```

Ele irá retornar um erro semelhante ao abaixo:

```bash
Error from server (BadRequest): error when creating "ingress-4.yaml": admission webhook "validate.nginx.ingress.kubernetes.io" denied the request: host "_" and path "/" is already defined in ingress default/giropops-senhas
```

Ele bloqueou a criação porque você não pode ter duas aplicações com o mesmo host e path. Para resolver isso, você precisa definir um novo host para a aplicação.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: giropops-senhas
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: senhas.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: giropops-senhas
            port:
              number: 5000
```

Como estamos utilizando o Kind, você precisa adicionar o host `giropops.ngix.io` no arquivo `/etc/hosts` do seu sistema.

```bash
sudo nano /etc/hosts
```

Adicione a linha abaixo no inicio do arquivo:

```bash
127.0.1.1       nginx.io
```

Faça o mesmo para a aplicação de senhas.

## Criando um cluster EKS

Para criar um cluster EKS, você precisa ter o AWS CLI instalado e configurado. Você também precisa ter o eksctl instalado. Agora para criar um cluster EKS, execute o comando abaixo:

```bash
eksctl create cluster --name eks-cluster --version=1.30 --region us-east-1 --nodegroup-name standard-workers --node-type t2.micro --nodes 2 --nodes-min 1 --nodes-max 3 --managed 
```

## Entendendo os Contexts para gerenciar vários clusters

O `kubectl` suporta múltiplos clusters e contextos. Você pode usar o comando `kubectl config get-contexts` para listar todos os contextos disponíveis. Para verificar o contexto vigente use:

```bash
kubectl config current-context
```

Para usar um contexto diferente você pode usar o comando `kubectl config use-context`:

```bash
kubectl config use-context <context-name>
```
