# Dockerizando a aplicação

Para iniciar o empacotamento em Docker, precisamos construir um *Dockerfile*, um arquivo de texto simples que contém instruções e as dependências para que a nossa aplicação funcione. A primeira versão da aplicação é:

```
FROM python:3.11.8

WORKDIR /app

COPY requirements.txt .

COPY app.py .

COPY templates templates/ 

COPY static static/ 

RUN pip install no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]
```

1. Construa a imagem docker:
```
 docker build -t giropops-senhas:1.0 . 
```

2. Executando o redis:
```
docker run -d --name redis -p 6379:6379 redis 
```

3. Descubra o IPAddress do Redis:

```
docker inspect ID_REDIS | grep IPAddress
```

4. Executando a aplicação:
```
docker run -d --name giropops-senhas -p 5000:5000 --env REDIS_HOST=IP_REDIS giropops-senhas:1.0
```

5. Verificando variáveis de ambiente da aplicação:

Entre no container com:

```
docker exec -ti ID_DO_CONTAINER bash
env
```
