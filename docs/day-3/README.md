# Dockerização do Projeto

Para dockerizar o projeto, siga estas etapas:

1. Construa a imagem docker:

```
docker build -t nataliagranato/linuxtips-giropops-senhas:1.0 .
```

2. Inicie um contêiner Redis:

```
docker container run -d -p 6000:6379 --name redis redis:alpine3.19
```

3. Descubra o IPAddress do Redis:

```
docker inspect ID_REDIS | grep IPAddress
```

4. Executando a aplicação:

```
docker run -d --name giropops-senhas -p 5000:5000 --env REDIS_HOST=IP_REDIS giropops-senhas:5.0
```

Ou

5. Use o Docker Compose para construir e iniciar os serviços:

```
docker-compose up -d
```

Isso iniciará tanto a aplicação quanto o contêiner Redis. A aplicação estará disponível em <http://localhost:5000/>.

Certifique-se de que todas as portas necessárias estejam liberadas e de que não haja conflitos com outras aplicações em execução em sua máquina.

Observação: As versões dos pacotes e dependências podem variar. Certifique-se de usar as versões mais recentes e compatíveis com seu ambiente.


# Verificando as Camadas das Imagens

Para entender melhor as camadas de uma imagem Docker e suas implicações em termos de segurança e otimização, é possível usar o comando docker history. Esse comando fornece um histórico das camadas de uma imagem Docker, juntamente com informações sobre como cada camada foi criada.

Por exemplo, para analisar o histórico da imagem nataliagranato/linuxtips-giropops-senhas:1.0, execute o seguinte comando:

```
docker history nataliagranato/linuxtips-giropops-senhas:1.0

```

Uma imagem com várias camadas e com um tamanho maior aumenta as chances de possuir maiores vulnerabilidades.

Para diminuir as camadas das imagens e, consequentemente, reduzir as vulnerabilidades, algumas recomendações:

1. **Combine Comandos RUN**:
   - Agrupe comandos RUN em uma única instrução sempre que possível. Isso reduzirá o número de camadas criadas. Por exemplo:


```
# Ruim
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2

# Bom
RUN apt-get update && \
    apt-get install -y package1 package2

```


2. **Remova Pacotes Temporários**: Limpe pacotes temporários após a instalação para evitar que eles permaneçam nas camadas da imagem. Por exemplo:


```
RUN apt-get install -y package1 package2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

3. **Use Multi-Stage Builds**: Utilize multi-stage builds para compilar e construir aplicações em uma etapa e, em seguida, copiar apenas os artefatos necessários para a imagem final. Isso ajuda a manter a imagem final limpa e reduzir seu tamanho. Por exemplo:

```
# Stage 1: Compilação do aplicativo Go
FROM golang:1.17 AS builder

WORKDIR /app

# Copia o código-fonte para o contêiner
COPY . .

# Compila o aplicativo Go
RUN go build -o myapp .

# Stage 2: Imagem final
FROM debian:buster-slim

WORKDIR /app

# Copia o executável do estágio de compilação para a imagem final
COPY --from=builder /app/myapp .

# Define o comando padrão para executar o aplicativo quando o contêiner for iniciado
CMD ["./myapp"]
```

A partir disso, temos uma melhoria na construção das nossas aplicações, mas também precisamos nos atentar para o aspecto da segurança, para isso temos diversos utilitários que podem nos ajudar nesse caminho.


## Reduzir Vulnerabilidades

A segurança é uma preocupação fundamental ao lidar com imagens Docker. Aqui estão algumas práticas recomendadas para reduzir vulnerabilidades:

### 1. Atualize Regularmente

Mantenha suas imagens Docker atualizadas aplicando patches e atualizações de segurança regularmente. Isso garante que as últimas correções de segurança estejam presentes na imagem.

### 2. Minimize Pacotes Instalados

Instale apenas os pacotes necessários na imagem. Quanto menos software estiver presente, menor será a superfície de ataque e menos vulnerabilidades potenciais estarão presentes na imagem.

### 3. Use Imagens Oficiais e Confiáveis

Utilize imagens oficiais e confiáveis do Docker Hub ou de repositórios verificados para garantir que as imagens base sejam mantidas e atualizadas regularmente.

### 4. Varredura de Vulnerabilidades

Utilize ferramentas de varredura de vulnerabilidades, como o Trivy ou o Clair, para identificar e corrigir vulnerabilidades conhecidas nas imagens Docker.

### 5. Monitoramento Contínuo

Implemente um processo de monitoramento contínuo para suas imagens Docker, verificando regularmente as vulnerabilidades e aplicando correções conforme necessário.

Ao seguir essas práticas recomendadas, você poderá reduzir o risco de vulnerabilidades em suas imagens Docker, garantindo a segurança e confiabilidade de suas aplicações em contêineres.



### Análise de vulnerabilidades com o Trivy


#### Informações Iniciais:
- O `trivy` informa que a varredura de vulnerabilidades está ativada, assim como a verificação de segredos.
- Ele fornece uma dica sobre como desativar a verificação de segredos caso a varredura esteja lenta.

#### Detecção do Sistema Operacional:
- O `trivy` detecta o sistema operacional utilizado na imagem Docker, que no caso é Debian.

#### Varredura de Vulnerabilidades:
- O `trivy` inicia a varredura de vulnerabilidades específicas para o sistema operacional Debian.
- Ele mostra o número total de arquivos específicos da linguagem (como arquivos Python no caso da imagem) que foram analisados.

#### Lista de Vulnerabilidades:
- A lista mostra cada biblioteca ou componente da imagem com suas vulnerabilidades associadas.
- Cada entrada inclui detalhes como o nome da biblioteca, a vulnerabilidade, a gravidade, o status (por exemplo, se está afetado ou se há uma correção disponível), a versão instalada, a versão corrigida (se houver), e um título resumindo a vulnerabilidade.

### Como Corrigir as Vulnerabilidades Usando o Trivy:

1. **Atualize as Bibliotecas/Componentes**:
   - Identifique as bibliotecas/componentes listados com vulnerabilidades.
   - Para cada biblioteca, verifique se há uma versão corrigida disponível.
   - Atualize as bibliotecas/componentes para versões que corrijam as vulnerabilidades listadas.

2. **Reconstrua a Imagem Docker**:
   - Depois de atualizar as bibliotecas/componentes, reconstrua a imagem Docker utilizando a nova versão das bibliotecas/componentes.
   - Certifique-se de atualizar o arquivo Dockerfile ou o processo de construção conforme necessário.

3. **Refaça a Varredura de Vulnerabilidades**:
   - Após reconstruir a imagem Docker com as atualizações, execute novamente o `trivy` para verificar se as vulnerabilidades foram corrigidas.
   - Certifique-se de que todas as vulnerabilidades listadas anteriormente tenham sido resolvidas.

4. **Mantenha o Processo Regularmente**:
   - A varredura e correção de vulnerabilidades devem ser um processo regular durante o ciclo de vida do aplicativo.
   - Configure processos automatizados para realizar varreduras de vulnerabilidades regularmente e para aplicar atualizações conforme necessário.
