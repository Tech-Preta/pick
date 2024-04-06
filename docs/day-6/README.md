# O que é o Docker Compose?

O Docker Compose é uma ferramenta exclusiva para a plataforma Docker, projetada especificamente para gerenciar containers. Ele não é compatível com outras plataformas de containers.

Para ilustrar as funcionalidades do Docker Compose, vamos analisar o seguinte exemplo de um arquivo docker-compose.yml:

```yaml
version: '3.9'

services:
  giropops-senhas:
    build: .
    ports:
      - "5000:5000"
    networks:
      - giropops-senhas
    environment:
      - REDIS_HOST=redis
    volumes:
      - natalia:/granato
    deploy:
      replicas: 1
      resources:
        reservations:
          cpus: '0.25'
          memory: 128M
        limits:
          cpus: '0.50'
          memory: 256M

  redis:
    image: redis
    command: redis-server --appendonly yes
    networks:
      - giropops-senhas
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
networks:
  giropops-senhas:
    driver: bridge

volumes:
  natalia:
```

Neste exemplo, temos dois serviços definidos: `giropops-senhas` e `redis`. O serviço giropops-senhas é construído a partir do Dockerfile no diretório atual (indicado pelo ponto), expõe a porta 5000 e usa a rede `giropops-senhas`. Além disso, ele define uma variável de ambiente `REDIS_HOST` e utiliza um volume chamado natalia.

Já o serviço redis utiliza a imagem oficial do Redis do Docker Hub, executa o servidor Redis em modo append-only e também usa a rede giropops-senhas. Além disso, ele possui um healthcheck que verifica a saúde do serviço a cada 30 segundos.

A rede `giropops-senhas` é definida como uma rede do tipo bridge, e o volume natalia é criado sem qualquer configuração adicional.

Este exemplo demonstra a flexibilidade e o poder do Docker Compose na definição e gerenciamento de múltiplos containers e suas interações.

## Alguns comandos para facilitar o seu dia a dia

O Docker Compose é uma ferramenta que permite definir e gerenciar aplicativos multi-container. Ele utiliza um arquivo de configuração chamado docker-compose.yml para especificar os serviços, redes e volumes necessários para a execução desses contêineres.

Aqui estão algumas das instruções que você mencionou e o que elas fazem:

- `docker compose up -d`: Inicia os serviços definidos no arquivo docker-compose.yml em segundo plano (-d). Isso cria e inicia os contêineres conforme as configurações especificadas.
- `docker compose ps`: Exibe o status dos serviços definidos no arquivo docker-compose.yml. Mostra quais contêineres estão em execução, parados ou com erro.
- `docker compose down`: Encerra todos os serviços e contêineres definidos no arquivo docker-compose.yml. Isso também remove as redes e volumes associados.
- `docker compose pause`: Pausa a execução dos serviços e contêineres definidos no arquivo docker-compose.yml. Isso pode ser útil para depurar ou realizar manutenção.
- `docker compose unpause`: Retoma a execução dos serviços e contêineres pausados.
- `docker compose logs -f`: Exibe os logs dos serviços em tempo real (-f). Isso é útil para depurar problemas ou monitorar a saída dos contêineres.

## Docker compose build, replicas e resources

### Funcionalidade `build`

A funcionalidade build é utilizada no arquivo docker-compose.yml para construir a imagem de um serviço a partir de um Dockerfile localizado no diretório atual. Isso permite personalizar a imagem do serviço antes de executá-lo.

Exemplo:
  
  ```yaml
services:
  giropops-senhas:
    build: .
  ```

Neste exemplo, o serviço giropops-senhas está sendo construído a partir do Dockerfile localizado no diretório atual (.).

### Funcionalidade replicas

A funcionalidade `replicas` define o número de réplicas de um serviço que serão criadas e executadas. Ela permite dimensionar horizontalmente os serviços, distribuindo a carga entre várias instâncias do mesmo serviço.

Exemplo:
  
    ```yaml
services:
  giropops-senhas:
    ...
    deploy:
      replicas: 3

```

Neste exemplo, o serviço `giropops-senhas` terá três réplicas em execução.

### Funcionalidade resources

A funcionalidade resources permite definir limites e reservas de recursos para um serviço. Isso inclui especificações de CPU e memória para garantir que os recursos sejam alocados de forma eficiente e equitativa entre os serviços.

Exemplo:
    
      ```yaml
services:
  giropops-senhas:
    ...
    deploy:
      resources:
        reservations:
          cpus: '0.25'
          memory: 128M
        limits:
          cpus: '0.50'
          memory: 256M
```

Neste exemplo, o serviço `giropops-senhas` tem uma reserva de 0,25 CPUs e 128MB de memória por réplica, com um limite máximo de 0,50 CPUs e 256MB de memória por réplica.

## Comandos úteis do Docker Compose

Essas funcionalidades fornecem flexibilidade e controle sobre a construção, replicação e alocação de recursos dos serviços definidos no arquivo `docker-compose.yml`.

- `docker compose -f docker-compose.yml up -d`: Inicia os serviços definidos no arquivo docker-compose.yml em segundo plano (-d). Isso cria e inicia os contêineres conforme as configurações especificadas.

- `docker compose -f docker-compose.yml up -d --scale redis=3`: Inicia os serviços definidos no arquivo docker-compose.yml em segundo plano (-d) e escala o serviço redis para 3 réplicas. Isso cria e inicia múltiplos contêineres do serviço redis.

- `docker compose -f docker-compose.yml build`: Constrói as imagens dos serviços definidos no arquivo docker-compose.yml. Isso é útil quando você fez alterações nos Dockerfiles ou nas configurações dos serviços.

Esses comandos são úteis para gerenciar e monitorar os serviços definidos no arquivo `docker-compose.yml` de forma eficiente e eficaz.

# Qual é a diferença entre Docker e Docker Compose?

- **Docker**:

O Docker é uma plataforma de virtualização de contêineres que permite empacotar, distribuir e executar aplicativos em ambientes isolados chamados contêineres. Ele fornece uma maneira consistente de empacotar aplicativos, suas dependências e configurações em um único pacote. Cada contêiner é uma instância isolada de um aplicativo, com seu próprio sistema de arquivos, bibliotecas e recursos. O Docker usa imagens para criar contêineres. As imagens são como modelos que contêm todas as instruções para criar um contêiner. É amplamente utilizado para desenvolvimento, teste e implantação de aplicativos.

- **Docker Compose**:

O Docker Compose é uma ferramenta que simplifica a orquestração de vários contêineres. Ele permite definir e gerenciar aplicativos multi-container usando um arquivo de configuração chamado docker-compose.yml. No arquivo docker-compose.yml, você pode especificar serviços, redes, volumes e outras configurações necessárias para seus contêineres. Com o Docker Compose, você pode iniciar, parar, escalar e gerenciar todos os contêineres de um aplicativo com um único comando. É útil para cenários em que você precisa executar vários contêineres juntos, como aplicativos que dependem de bancos de dados, cache, servidores web, etc.

Em resumo, o Docker é a base para criar e executar contêineres individuais, enquanto o Docker Compose é usado para definir e gerenciar aplicativos compostos por vários contêineres interconectados. Ambos são essenciais para o desenvolvimento e implantação eficiente de aplicativos baseados em contêineres. 🐳

Espero que essas informações sejam úteis para você! Se tiver mais dúvidas ou precisar de mais informações, não hesite em perguntar.
