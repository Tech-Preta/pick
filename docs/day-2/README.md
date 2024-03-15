# Dockerfile e Imagens de Containers

### Imagens de Container

As imagens de container são pacotes leves, autônomos e executáveis que contêm todo o necessário para executar um software, incluindo o código, runtime, bibliotecas, variáveis de ambiente e configurações. Elas são utilizadas para criar e executar containers, que são instâncias em tempo de execução das imagens de container. As imagens de container são criadas a partir de um Dockerfile e são armazenadas em repositórios, como Docker Hub, para fácil distribuição e compartilhamento.

### Dockerfile

Um Dockerfile é um arquivo de texto simples que contém uma lista de instruções usadas para construir uma imagem de container. Ele descreve os passos necessários para criar uma imagem específica. Cada instrução no Dockerfile adiciona uma nova camada à imagem, permitindo a reutilização de camadas existentes e otimizando o processo de construção.

### Exemplo de Dockerfile

```
# Este Dockerfile cria uma imagem baseada no Alpine Linux e instala o Nginx.
# Ele expõe a porta 80 e inicia o servidor Nginx.

FROM alpine:latest
# A instrução FROM especifica a imagem base para a imagem Docker que está sendo construída.
# Neste caso, utiliza a imagem do Alpine Linux como base.

RUN apk update && apk add nginx
# A instrução RUN executa um comando dentro da imagem Docker durante o processo de construção.
# Neste caso, ela atualiza as listas de pacotes e instala o Nginx usando o gerenciador de pacotes apk.

# Expõe a porta 80 para tráfego HTTP.
EXPOSE 80

# O comando CMD especifica o comando a ser executado quando o contêiner é iniciado.
# Neste caso, inicia o servidor Nginx.
CMD ["nginx", "-g", "daemon off;"]
```

### Buildando uma imagem

Para construir uma imagem a partir de um Dockerfile, utilize o comando docker build seguido do nome da imagem e da versão:

```
docker build -t pick:v1.0.0 . 
```

### Listando imagens

Para listar todas as imagens disponíveis localmente, utilize o comando:

```
docker imagens
```

### Iniciando o Container com a Imagem Recém Criada

Para iniciar um container usando a imagem recém-criada, utilize o comando docker run. Este comando também permite especificar opções como mapeamento de portas e nome do container:

```
docker run -p 8080:80 -d --name meu_container pick:v1.1.1
```

### Dockerfile Descomplicado

## Principais Instruções

- ADD: Copia novos arquivos, diretórios, arquivos TAR ou arquivos remotos e os adiciona ao filesystem do container.
- CMD: Executa um comando quando o container é iniciado.
- LABEL: Adiciona metadados à imagem.
- COPY: Copia novos arquivos e diretórios para o filesystem do container.
- ENTRYPOINT: Configura um container para rodar um executável.
- ENV: Informa variáveis de ambiente ao container.
- EXPOSE: Informa qual porta o container estará ouvindo.
- FROM: Indica qual imagem será utilizada como base.
- MAINTAINER: Especifica o autor da imagem.
- RUN: Executa qualquer comando em uma nova camada na imagem.
- USER: Determina qual usuário será utilizado na imagem.
- VOLUME: Permite a criação de um ponto de montagem no container.
- WORKDIR: Responsável por mudar do diretório "/" para o especificado nele.

### Desafio técnico

O Dockerfile abaixo cria uma imagem baseada no Alpine Linux e instala o Nginx:

```
# Este Dockerfile cria uma imagem baseada no Alpine Linux e instala o Nginx.
# Ele expõe a porta 80 e inicia o servidor Nginx.

FROM alpine:latest
# A instrução FROM especifica a imagem base para a imagem Docker que está sendo construída.
# Neste caso, utiliza a imagem do Alpine Linux como base.

RUN apk update && apk add nginx
# A instrução RUN executa um comando dentro da imagem Docker durante o processo de construção.
# Neste caso, ela atualiza as listas de pacotes e instala o Nginx usando o gerenciador de pacotes apk.

# Expõe a porta 80 para tráfego HTTP.
EXPOSE 80

# O comando CMD especifica o comando a ser executado quando o contêiner é iniciado.
# Neste caso, inicia o servidor Nginx.
CMD ["nginx", "-g", "daemon off;"]
```

Para construir a imagem Docker, utilize o comando **docker build -t giropops-web .**, e para executar o contêiner, utilize **docker run -p 80:80 --name giropops-web giropops-web**.
