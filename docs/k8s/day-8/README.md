# Secrets do Kubernetes

## O que são as Secrets do Kubernetes?

Secrets do Kubernetes são objetos que permitem armazenar e gerenciar informações sensíveis, como senhas, tokens OAuth, chaves ssh e etc. Ao usar Secrets, você pode controlar o modo de uso de informações sensíveis em um ambiente de aplicativo, sem incluí-las no aplicativo ou na imagem do contêiner.

## Conhecendo todos os tipos de Secrets e o que é a codificação base64

Existem vários tipos de Secrets que você pode criar, como:

- **Opaque**: é o tipo padrão quando nada é especificado. Opaque é usado para armazenar informações arbitrárias, representadas como um mapa de strings para bytes.
- **kubernetes.io/service-account-token**: contém um token que identifica uma conta de serviço.
- **kubernetes.io/dockercfg**: contém um arquivo de configuração que pode ser usado para autenticar a um registro de contêiner.
- **kubernetes.io/dockerconfigjson**: é uma versão do dockercfg que permite a configuração de vários registros de contêineres.
- **kubernetes.io/basic-auth**: contém dados necessários para a autenticação básica.
- **kubernetes.io/ssh-auth**: contém dados necessários para a autenticação SSH.
- **kubernetes.io/tls**: contém informações que podem ser usadas para realizar uma resposta de desafio TLS.

A codificação base64 é um esquema de codificação binário para texto que é usado quando há uma necessidade de codificar dados binários, especialmente ao esses dados precisam ser armazenados e transferidos pela internet.

Para codificar uma string em base64, você pode usar o comando `echo -n 'minha-string' | base64` e para decodificar uma string em base64, você pode usar o comando `echo -n 'minha-string-base64' | base64 -d`.

Para decodificar uma string em base64, você pode usar o comando `echo -n 'minha-string-base64' | base64 -d`.

## Criando uma Secret do tipo Opaque

Para criar uma Secret do tipo Opaque, você pode usar o comando `kubectl create secret generic minha-secret --from-literal=username=admin --from-literal=password=senha123` seguido pelo nome da Secret e os dados a serem incluídos. Por exemplo:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: minha-secret
type: Opaque
data:
  username: YWRtaW4=  # 'admin' codificado em base64
  password: c2VuaGExMjM=  # 'senha123' codificado em base64
```

## Utilizando o nosso Secret como variável de ambiente dentro do Pod

Você pode usar Secrets como variáveis de ambiente dentro de um Pod adicionando-as à seção `env` ou `envFrom` da especificação do Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: giropops-pod
spec:
  containers:
  - name: giropops-container
    image: nginx
    env: 
      valueFrom:
        secretKeyRef: 
          name: giropops-secret 
          key: username  
    - name: PASSWORD  
      valueFrom:
        secretKeyRef:
          name: giropops-secret 
          key: password 
```

Para verificar se a Secret está como variável de ambiente dentro do Pod, você pode usar o comando `kubectl exec -it giropops-pod -- env` para visualizar as variáveis de ambiente do Pod.

```bash
kubectl exec giropops-pod -- env
```

## Criando uma Secret para autenticação no Docker Hub

Primeiro passo é pegar o conteúdo do seu arquivo config.json e codificar em base64, e para isso você pode usar o comando base64:

```bash
cat ~/.docker/config.json | base64
```

Agora crie um arquivo chamado `docker-secret.yaml` e adicione o seguinte conteúdo:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-hub-secret 
type: kubernetes.io/dockerconfigjson # tipo do Secret
data:
  .dockerconfigjson: |  # conteúdo do arquivo config.json codificado em base64
    QXF1aSB0ZW0gcXVlIGVzdGFyIG8gY29udGXDumRvIGRvIHNldSBjb25maWcuanNvbiwgY29pc2EgbGluZGEgZG8gSmVmaW0=
```

Para criar uma Secret para autenticação no Docker Hub, você pode usar o comando `kubectl create secret docker-registry` seguido pelo nome da Secret e as credenciais do Docker Hub.

## Criando um Secret do tipo TLS

Para criar um Secret do tipo TLS, você pode usar o comando `kubectl create secret tls meu-servico-web-tls-secret --cert=certificado.crt --key=chave-privada.key` seguido sempre pelo nome da Secret e a localização dos arquivos de certificado e chave.

Verificando os dados de uma Secret, você pode usar o comando `kubectl get secret meu-servico-tls-secret -o yaml` para visualizar os dados de uma Secret.

Ou você pode usar o comando `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout chave-privada.key -out certificado.crt` para criar um certificado autoassinado.

Aqui está um exemplo do arquivo de configuração do nginx para utilizar tls:

```yaml
http {
    server {
        listen 80;
        listen 443 ssl;
        ssl_certificate /etc/nginx/tls/certificado.crt;
        ssl_certificate_key /etc/nginx/tls/chave-privada.key;

        location / {
            return 200 'Hello, World!';
            add_header Content-Type text/plain;
        }
    }
}
```

# Criando um ConfigMap para adicionar um arquivo no Pod e configurar o SSL no Nginx

Para criar um ConfigMap para adicionar um arquivo no Pod e configurar o SSL no Nginx, você pode usar o comando `kubectl create configmap nginx-config --from-file=nginx.conf` seguido pelo nome do ConfigMap e o arquivo a ser incluído.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: giropops-pod
  labels:
    app: giropops-pod
spec:
  containers:
  - name: giropops-container
    image: nginx:1.26
    ports:
    - containerPort: 80
    - containerPort: 443
    volumeMounts:
    - name: meu-volume
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf
    - name: nginx-tls
      mountPath: /etc/nginx/tls
  volumes:
  - name: nginx-config-volume
    configMap:
      name: nginx-config
  - name: nginx-tls
    secret:
      secretName: meu-servico-tls-secret
      items:
      - key: certificado.crt
        path: certificado.crt
      - key: chave-privada.key
        path: chave-privada.key
```

Recapirulando, aprendemos o que são as Secrets do Kubernetes, os tipos de Secrets e o que é a codificação base64, como criar uma Secret do tipo Opaque, como utilizar o nosso Secret como variável de ambiente dentro do Pod, como criar uma Secret para autenticação no Docker Hub, como criar um Secret do tipo TLS e como criar um ConfigMap para adicionar um arquivo no Pod e configurar o SSL no Nginx.

Para realizar o passo a passo:

1. Crie o seu certificado TLS: `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout chave-privada.key -out certificado.crt`.

2. Crie a secret do tipo TLS com o comando `kubectl create secret tls meu-servico-tls-secret --cert=certificado.crt --key=chave-privada.key`.

3. Crie o ConfigMap com o comando `kubectl create configmap nginx-config --from-file=nginx.conf`.

4. Crie o Pod com o comando `kubectl apply -f nginx-pod.yml`.

5. Crie um service para expor o Pod criado com o comando `kubectl expose pod nginx`. Liste o service com `kubectl get svc`.

6. Faça o port-forward do service para acessar o Nginx com o comando `kubectl port-forward service/nginx 4443:443`.

Para testar o Nginx, acesse o endereço `https://localhost:4443` ou `https://127.0.0.1:4443` e você verá a mensagem `Bem-vindo ao Nginx!`.

Você também pode utilizar o `curl -k https://localhost:4443` e verá a seguinte mensagem:

Bem-vindo ao Nginx!
