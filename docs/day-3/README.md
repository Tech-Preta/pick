# Dockerização do Projeto

Para dockerizar o projeto, siga estas etapas:

1. **Construa a imagem docker**:

```
docker build -t nataliagranato/linuxtips-giropops-senhas:1.0 .
```

2. **Inicie um contêiner Redis**:

```
docker container run -d -p 6000:6379 --name redis redis:alpine3.19
```

3. **Descubra o IPAddress do Redis**:

```
docker inspect ID_REDIS | grep IPAddress
```

4. **Executando a aplicação**:

```
docker run -d --name giropops-senhas -p 5000:5000 --env REDIS_HOST=IP_REDIS giropops-senhas:5.0
```

Ou

5. **Use o Docker Compose** para construir e iniciar os serviços:

```
docker-compose up -d
```

Isso iniciará tanto a aplicação quanto o contêiner Redis. A aplicação estará disponível em <http://localhost:5000/>.

**Certifique-se de que todas as portas necessárias estejam liberadas e de que não haja conflitos com outras aplicações em execução em sua máquina.**

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

Para verificar vulnerabilidades na sua imagem, use o comando abaixo:

```
trivy image nataliagranato/linuxtips-giropops-senhas:2.0
```

Este comando fornecerá uma análise detalhada das vulnerabilidades presentes na imagem, permitindo que você conheça as vulnerabilidades, saiba como corrigir e etc. 

- O exemplo de saída desse comando, pode ser consultado aqui: https://github.com/nataliagranato/giropops-senhas/blob/develop/vulnerabilidades.txt


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


### Experimentando o Docker Scout:

- Faça a sua autenticação com `docker login` e utilize o comando abaixo para conhecer as CVEs, ou Common Vulnerabilities and Exposures, identificadores únicos atribuídos a vulnerabilidades de segurança específicas em software ou hardware. 

```
docker scout cves nataliagranato/linuxtips-giropops-senhas:3.0
```


A saída será semelhante a isso:

```
    i New version 1.6.0 available (installed version is 1.3.0) at https://github.com/docker/scout-cli
    ✓ Image stored for indexing
    ✓ Indexed 65 packages
    ✗ Detected 1 vulnerable package with 2 vulnerabilities


## Overview

                    │                 Analyzed Image                  
────────────────────┼─────────────────────────────────────────────────
  Target            │  nataliagranato/linuxtips-giropops-senhas:3.0   
    digest          │  e37d53bc7930                                   
    platform        │ linux/amd64                                     
    vulnerabilities │    0C     1H     1M     0L                      
    size            │ 30 MB                                           
    packages        │ 65                                              


## Packages and Vulnerabilities

   0C     1H     1M     0L  redis 4.5.4
pkg:pypi/redis@4.5.4

    ✗ HIGH CVE-2023-31655
      https://scout.docker.com/v/CVE-2023-31655?s=pypa&n=redis&t=pypi&vr=%3D4.5.4
      Affected range : =4.5.4     
      Fixed version  : not fixed  
    
    ✗ MEDIUM CVE-2023-28859
      https://scout.docker.com/v/CVE-2023-28859?s=pypa&n=redis&t=pypi&vr=%3C5.0.0b1
      Affected range : <5.0.0b1  
      Fixed version  : 5.0.0b1   
    


2 vulnerabilities found in 1 package
  LOW       0  
  MEDIUM    1  
  HIGH      1  
  CRITICAL  0  


What's Next?
  View base image update recommendations → docker scout recommendations nataliagranato/linuxtips-giropops-senhas:3.0

```

Para ver as recomendações do Docker Scout utilize:

```
docker scout recommendations nataliagranato/linuxtips-giropops-senhas:3.0
```


### Assinando suas imagens com o Cosign

O Cosign facilita a assinatura das imagens de container, que atesta que aquela imagem realmente foi construída por você, adicionando uma assinatura digital usando uma chave privada para garantir a integridade e a proveniência da imagem.

Agora vamos assinar uma imagem e publicar no Docker Hub, o registry público do Docker.

1. **Gerando o certificado e o par de chaves**:

```
cosign generate-key-pair
```

2. **Assinando a nossa imagem**:

```
cosign sign --key cosign.key nataliagranato/linuxtips-giropops-senhas:e0942c7-20240319161939
```

- Será solicitado a senha da chave privada que você criou, insira a senha, depois disso você será perguntado se deseja enviar ao repositório remoto.


Você verá uma saída semelhante a:

```
Enter password for private key: 
WARNING: Image reference nataliagranato/linuxtips-giropops-senhas:e0942c7-20240319161939 uses a tag, not a digest, to identify the image to sign.
    This can lead you to sign a different image than the intended one. Please use a
    digest (example.com/ubuntu@sha256:abc123...) rather than tag
    (example.com/ubuntu:latest) for the input to cosign. The ability to refer to
    images by tag will be removed in a future release.


        The sigstore service, hosted by sigstore a Series of LF Projects, LLC, is provided pursuant to the Hosted Project Tools Terms of Use, available at https://lfprojects.org/policies/hosted-project-tools-terms-of-use/.
        Note that if your submission includes personal data associated with this signed artifact, it will be part of an immutable record.
        This may include the email address associated with the account with which you authenticate your contractual Agreement.
        This information will be used for signing this artifact and will be stored in public transparency logs and cannot be removed later, and is subject to the Immutable Record notice at https://lfprojects.org/policies/hosted-project-tools-immutable-records/.

By typing 'y', you attest that (1) you are not submitting the personal data of any other person; and (2) you understand and agree to the statement and the Agreement terms at the URLs listed above.
Are you sure you would like to continue? [y/N] y
tlog entry created with index: 79606777
Pushing signature to: index.docker.io/nataliagranato/linuxtips-giropops-senhas
```


3. **Verificando a autenticidade de uma imagem**:

      - Você deve trocar a key para o par de chave pública gerado com a sua chave privada.

```
cosign verify --key cosign.pub nataliagranato/linuxtips-giropops-senhas:e0942c7-20240319161939
```

A saída será semelhante a:

```
Verification for index.docker.io/nataliagranato/linuxtips-giropops-senhas:e0942c7-20240319161939 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"index.docker.io/nataliagranato/linuxtips-giropops-senhas"},"image":{"docker-manifest-digest":"sha256:8bb7196e06cfa5e58e1a686584d7a972bd1a371b66309b7452976ef1bd2bbaf5"},"type":"cosign container image signature"},"optional":{"Bundle":{"SignedEntryTimestamp":"MEUCIQCWtamqxtW2029TmBmmUNOUplkhenX1A+7SMimyeKNdiwIgGPM3GzRwi9dCWufRqQlXth318GWWUM4kBLoK6N/KuJ4=","Payload":{"body":"eyJhcGlWZXJzaW9uIjoiMC4wLjEiLCJraW5kIjoiaGFzaGVkcmVrb3JkIiwic3BlYyI6eyJkYXRhIjp7Imhhc2giOnsiYWxnb3JpdGhtIjoic2hhMjU2IiwidmFsdWUiOiI3YmEwYjhiOWY3MTcyNjJjM2IzMWI1NjQzYTZmYjhhMTU0MjI3MWVlZTQ5NTRiYzc0NzU0NmNjYjI4Yjk0ZDUyIn19LCJzaWduYXR1cmUiOnsiY29udGVudCI6Ik1FVUNJUURNTit5VUtGYk5PQWxsNUFpSExNWmNSekYvcWZxekp5eEZCaUJqOUU2NnFRSWdLWFlWSDhZelEvbUZvdytFUVRHaTZpNlBQWkh0UDk1NlVJa3QvS3RpcUJjPSIsInB1YmxpY0tleSI6eyJjb250ZW50IjoiTFMwdExTMUNSVWRKVGlCUVZVSk1TVU1nUzBWWkxTMHRMUzBLVFVacmQwVjNXVWhMYjFwSmVtb3dRMEZSV1VsTGIxcEplbW93UkVGUlkwUlJaMEZGVDBRcmRIcGFUR3RSTkdKT2JXaDRkblpzTlRSM1psVlNWMjB6TmdveFVYSjRVVEZRU0hCbVZEaDBUbkF3ZGpsdk4zWTJNVFF2ZFZFeFJGTllUM0pZZFVWUE1GRXZXRzVXYUdkVU9HcDFabXBqV2sxck5WaEJQVDBLTFMwdExTMUZUa1FnVUZWQ1RFbERJRXRGV1MwdExTMHRDZz09In19fX0=","integratedTime":1710889924,"logIndex":79607170,"logID":"c0d23d6ad406973f9559f3ba2d1ca01f84147d8ffc5b8445c224f98b9591801d"}}}}]
```