# O que é um Service Monitor?

No contexto do Prometheus, um "Service Monitor" é um recurso personalizado do Kubernetes que permite ao Prometheus descobrir automaticamente os serviços a serem monitorados.

1. **Exposição de métricas**: Um endpoint de métricas exposto por uma aplicação em execução em um pod é mapeado para um serviço.
2. **Monitoramento de Serviço**: O endpoint de métricas mapeado para um serviço é exposto pelo serviço a um monitor de serviço.
3. **Descoberta de Serviço**: O operador do Prometheus descobre os endpoints expostos pelo monitor de serviço.
4. **Configuração do Prometheus**: O operador do Prometheus atualiza a configuração do Prometheus para incluir os endpoints expostos pelo monitor de serviço. O Prometheus agora raspará as métricas desses endpoints.

O Service Monitor deve ser configurado com a porta que seu serviço expõe suas métricas (e o caminho para essas métricas nessa porta) e definir o seletor para corresponder ao serviço.

Antes de tudo criaremos um configmap com as configurações do nginx:

```yaml
apiVersion: v1 # versão da API do Kubernetes
kind: ConfigMap # tipo do recurso
metadata: # metadados do recurso
  name: nginx-config # nome do recurso
data: # dados do recurso
  nginx.conf: | # conteúdo do arquivo nginx.conf
    server {
      listen 80;
      location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
      }
      location /metrics {
        stub_status on;
        access_log off;
      }
    }
```

Precisamos ter uma aplicação que exponha métricas. Para isso, vamos criar um exemplo de aplicação que expõe métricas. Aqui está um exemplo de como o arquivo `deployment.yaml` pode parecer:

```yaml
apiVersion: apps/v1 # versão da API do Kubernetes
kind: Deployment # tipo do recurso
metadata: # metadados do recurso
  name: nginx-server # nome do deployment
spec: # especificação do deployment
  selector: # seletor do deployment que será usado para selecionar os pods
    matchLabels: # labels do seletor que serão usados para selecionar os pods
      app: nginx # label que identifica o app
  replicas: 3 # número de réplicas do deployment
  template: # template do deployment
    metadata: # metadados do template
      labels: # labels do template
        app: nginx # label que identifica o app
      annotations: # annotations do template que serão usadas para adicionar informações adicionais
        prometheus.io/scrape: 'true' # annotation para definir que o Prometheus irá raspar as métricas
        prometheus.io/port: '9113' # annotation para definir a porta que o Prometheus irá usar para raspar as métricas
      containers: # containers do template
        - name: nginx # nome do container
          image: nginx # imagem do container
          ports: # portas do container
            - containerPort: 80 # porta do container
              name: http # nome da porta
          volumeMounts: # volumes do container que serão montados
            - name: nginx-config # nome do volume
              mountPath: /etc/nginx/conf.d/default.conf # caminho do volume
              subPath: nginx.conf # subcaminho do volume
        - name: nginx-exporter # nome do container do exporter
          image: 'nginx/nginx-prometheus-exporter:0.11.0' # imagem do exporter
          args: # argumentos do container
            - '-nginx.scrape-uri=http://localhost/metrics' # argumento para definir o URI que o exporter irá raspar
          resources: # recursos do container
            limits: # limites de recursos do container
              memory: 128Mi # limite de memória do container
              cpu: 0.3 # limite de CPU do container
          ports: # portas do container 
            - containerPort: 9113 # porta do container que será usada para expor as métricas
              name: metrics # nome da porta
      volumes: # volumes do template
        - configMap: # configmap do volume, que será usado para montar o volume
            defaultMode: 420 # modo padrão do volume, esse valor define as permissões do volume
            name: nginx-config # nome do configmap
          name: nginx-config # nome do volume
```

Também precisamos de um service para expor a aplicação. Aqui está um exemplo de como o arquivo `service.yaml` pode parecer:

```yaml
apiVersion: v1 # versão da API do Kubernetes
kind: Service # tipo do recurso
metadata: # metadados do recurso
  name: nginx-svc # nome do recurso
  labels: # labels do recurso que serão usados para identificar o svc
    app: nginx # label que identifica o svc
spec: # especificação do svc
  ports: # portas do svc
  - port: 9113 # porta do svc
    name: metrics # nome da porta
  selector: # seletor do svc que será usado para selecionar os pods
    app: nginx # label que identifica o app que será selecionado pelo svc
```

Agora que possuímos o nosso arquivo de configuração, nosso deployment e service, podemos aplicar esses arquivos no Kubernetes. Para isso, execute o comando:

```bash
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Para configurar um Service Monitor no Prometheus é necessário seguir alguns passos. Aqui está um exemplo de como você pode fazer isso:

1. **Crie um service monitor**: Para monitorar a aplicação que acabamos de criar, você precisa criar um Service Monitor que irá descobrir o serviço que você acabou de criar. Aqui está um exemplo de como o arquivo `service-monitor.yaml` pode parecer:

```yaml
apiVersion: monitoring.coreos.com/v1 # versão da API do Prometheus Operator
kind: ServiceMonitor # tipo do recurso
metadata: # metadados do recurso
  name: nginx-servicemonitor # nome do recurso
  labels: # labels do recurso que serão usados para identificar o servicemonitor
    app: nginx # label que identifica a aplicação que será monitorada
spec: # especificação do recurso
  selector: # seletor para selecionar os pods que serão monitorados
    matchLabels: # labels que identificam os pods que serão monitorados pelo servicemonitor
      app: nginx # label que identifica o app que será monitorado pelo servicemonitor
  endpoints: # endpoints que serão monitorados 
    - interval: 10s # intervalo de tempo que o Prometheus irá fazer a coleta de métricas
      path: /metrics # caminho do endpoint que será monitorado
      targetPort: 9113 # porta do endpoint que será monitorado
```

**Atenção** o selector é um campo usado para selecionar os serviços que devem ser monitorados. No exemplo, `matchLabels: app: nginx` indica que o Service Monitor deve selecionar serviços que têm o label `app: nginx`.

A importância dessas informações estarem corretas é que elas determinam quais serviços serão monitorados pelo Prometheus. Se essas informações estiverem incorretas, o Prometheus pode não ser capaz de descobrir e raspar as métricas dos serviços corretos.

### Informações adicionais

- **apiVersion**: Versão da API do Kubernetes que estamos utilizando.
- **kind**: Tipo de objeto que estamos criando.
- **metadata**: Informações sobre o objeto que estamos criando.
  - **metadata.annotations**: Anotações que podemos adicionar ao nosso objeto.
  - **metadata.labels**: Labels que podemos adicionar ao nosso objeto.
  - **metadata.name**: Nome do nosso objeto.
  - **metadata.namespace**: Namespace onde o nosso objeto será criado.
- **spec**: Especificações do nosso objeto.
  - **spec.endpoints**: Endpoints que o nosso ServiceMonitor irá monitorar.
  - **spec.endpoints.interval**: Intervalo de tempo que o Prometheus irá fazer a coleta de métricas.
  - **spec.endpoints.port**: Porta que o Prometheus irá utilizar para coletar as métricas.
  - **spec.selector**: Selector que o ServiceMonitor irá utilizar para encontrar os serviços que ele irá monitorar.

# O que é um Pod Monitor?

No contexto do Prometheus, um "Pod Monitor" é um recurso personalizado do Kubernetes que permite ao Prometheus descobrir automaticamente os pods a serem monitorados.

1. **Exposição de métricas**: Um endpoint de métricas exposto por uma aplicação em execução em um pod é mapeado para um serviço.

2. **Monitoramento de Pod**: O endpoint de métricas mapeado para um serviço é exposto pelo serviço a um monitor de pod.

3. **Descoberta de Pod**: O operador do Prometheus descobre os endpoints expostos pelo monitor de pod.

4. **Configuração do Prometheus**: O operador do Prometheus atualiza a configuração do Prometheus para incluir os endpoints expostos pelo monitor de pod. O Prometheus agora raspará as métricas desses endpoints.

O Pod Monitor deve ser configurado com o nome do pod que deseja monitorar e o seletor para corresponder ao pod.

Para configurar um Pod Monitor no Prometheus é necessário seguir alguns passos. Aqui está um exemplo de como você pode fazer isso:

1. **Crie um pod**: Primeiro, você precisa criar um pod que expõe o endpoint de métricas da sua aplicação. Aqui está um exemplo de como o arquivo `pod.yaml` pode parecer:

```yaml
apiVersion: v1 # versão da API
kind: Pod # tipo de recurso, no caso, um Pod
metadata: # metadados do recurso
  name: nginx-pod # nome do recurso
  labels: # labels do recurso
    app: nginx # label que identifica o app
spec: # especificações do recursos
  containers: # containers do template 
    - name: nginx-container # nome do container
      image: nginx # imagem do container do Nginx
      ports: # portas do container
        - containerPort: 80 # porta do container
          name: http # nome da porta
      volumeMounts: # volumes que serão montados no container
        - name: nginx-config # nome do volume
          mountPath: /etc/nginx/conf.d/default.conf # caminho de montagem do volume
          subPath: nginx.conf # subpath do volume
    - name: nginx-exporter # nome do container que será o exporter
      image: 'nginx/nginx-prometheus-exporter:0.11.0' # imagem do container do exporter
      args: # argumentos do container
        - '-nginx.scrape-uri=http://localhost/metrics' # argumento para definir a URI de scraping
      resources: # recursos do container
        limits: # limites de recursos
          memory: 128Mi # limite de memória
          cpu: 0.3 # limite de CPU
      ports: # portas do container
        - containerPort: 9113 # porta do container que será exposta
          name: metrics # nome da porta
  volumes: # volumes do template
    - configMap: # configmap do volume, nós iremos criar esse volume através de um configmap
        defaultMode: 420 # modo padrão do volume
        name: nginx-config # nome do configmap
      name: nginx-config # nome do volume
```

2. **Crie um Pod Monitor**: Em seguida, você precisa criar um Pod Monitor que irá descobrir o pod que você acabou de criar. Aqui está um exemplo de como o arquivo pod-monitor.yaml pode parecer:

```yaml
apiVersion: monitoring.coreos.com/v1 # versão da API
kind: PodMonitor # tipo de recurso, no caso, um PodMonitor do Prometheus Operator
metadata: # metadados do recurso
  name: nginx-podmonitor # nome do recurso
  labels: # labels do recurso
    app: nginx # label que identifica o app
spec:
  namespaceSelector: # seletor de namespaces
    matchNames: # namespaces que serão monitorados
      - default # namespace que será monitorado
  selector: # seletor para identificar os pods que serão monitorados
    matchLabels: # labels que identificam os pods que serão monitorados
      app: nginx # label que identifica o app que será monitorado
  podMetricsEndpoints: # endpoints que serão monitorados
    - interval: 10s # intervalo de tempo entre as requisições
      path: /metrics # caminho para a requisição
      targetPort: 9113 # porta do target
```

**Atenção** o selector é um campo usado para selecionar os pods que devem ser monitorados. No exemplo, `matchLabels: app: myApplication` indica que o Pod Monitor deve selecionar pods que têm o label `app: myApplication`.

A importância dessas informações estarem corretas é que elas determinam quais pods serão monitorados pelo Prometheus. Se essas informações estiverem incorretas, o Prometheus pode não ser capaz de descobrir e raspar as métricas dos pods corretos.

### Comandos úteis

Verificar se o PodMonitor foi criado:

```bash
kubectl get podmonitor -n kube-prometheus-stack
```

Acesse o PodMonitor e verifique se o exporter está funcionando corretamente:

```bash
kubectl exec -it nginx-pod -c nginx-exporter -n pick -- bash
curl localhost:9113/metrics
```

### Informações adicionais

- **apiVersion**: Versão da API do Kubernetes que estamos utilizando.
- **kind**: Tipo de objeto que estamos criando.
- **metadata**: Informações sobre o objeto que estamos criando.
- **metadata.annotations**: Anotações que podemos adicionar ao nosso objeto.
- **metadata.labels**: Labels que podemos adicionar ao nosso objeto.
- **metadata.name**: Nome do nosso objeto.
- **metadata.namespace**: Namespace onde o nosso objeto será criado.
- **spec**: Especificações do nosso objeto.
- **spec.podMetricsEndpoints**: Endpoints que o nosso PodMonitor irá monitorar.
- **spec.podMetricsEndpoints.interval**: Intervalo de tempo que o Prometheus irá fazer a coleta de métricas.
- **spec.selector**: Selector que o PodMonitor irá utilizar para encontrar os pods que ele irá monitorar.

## Criando alertas com Prometheus e Alertmanager

O Prometheus é uma ferramenta de monitoramento de código aberto que coleta métricas de sistemas e aplicações. Ele armazena essas métricas em um banco de dados de séries temporais e fornece uma interface de consulta para visualizar e alertar com base nessas métricas.

O Alertmanager é uma ferramenta de gerenciamento de alertas de código aberto que trabalha em conjunto com o Prometheus para lidar com alertas enviados por clientes de monitoramento. Ele leva esses alertas e os envia para os sistemas de notificação apropriados.

Caso você não tenha um ingress configurado, você pode acessar o Prometheus e o Alertmanager através do `port-forward`. Para isso, execute os seguintes comandos:

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n kube-prometheus-stack
```

E para acessar o alertmanager:

```bash
kubectl port-forward svc/kube-prometheus-stack-alertmanager 9093:9093 -n kube-prometheus-stack
```

Para usar o port-foward você utiliza o comando `kubectl port-forward svc/<service-name> <local-port>:<service-port> -n <namespace>`.

No Kubernetes utilizando o pacote helm do `kube-prometheus-stack`, os alertas são configurados através do configmap'prometheus-kube-prometheus-stack-prometheus-rulefiles-0' que é criado automaticamente pelo pacote.

Para visualizar os alertas configurados, execute o comando:

```bash
kubectl get configmap prometheus-kube-prometheus-stack-prometheus-rulefiles-0 -n kube-prometheus-stack -o yaml
```

Para editar o configmap de alertas do Prometheus, execute o comando:

```bash
kubectl edit configmap prometheus-kube-prometheus-stack-prometheus-rulefiles-0 -n kube-prometheus-stack
```

Agora vamos criar um alerta no Prometheus e configurar o Alertmanager para lidar com esse alerta.

1. **Configurar alertas no Prometheus**: Primeiro, você precisa configurar regras de alerta no Prometheus. Aqui está um exemplo de como o arquivo `prometheus-rules.yaml` pode parecer:

```yaml
apiVersion: monitoring.coreos.com/v1 # Versão da api do PrometheusRule
kind: PrometheusRule # Tipo do recurso
metadata: # Metadados do recurso (nome, namespace, labels)
  annotations:
    meta.helm.sh/release-name: kube-prometheus-stack
    meta.helm.sh/release-namespace: kube-prometheus-stack
  name: nginx-prometheus-rule
  namespace: kube-prometheus-stack
  labels: # Labels do recurso
    app: kube-prometheus-stack
    role: alert-rules # Label que indica que o PrometheusRule contém regras de alerta
    app.kubernetes.io/name: kube-prometheus-stack # Label que indica que o PrometheusRule faz parte do kube-prometheus
    app.kubernetes.io/part-of: kube-prometheus-stack # Label que indica que o PrometheusRule faz parte do kube-prometheus
spec: # Especificação do recurso
  groups: # Lista de grupos de regras
  - name: nginx-prometheus-rule # Nome do grupo de regras
    rules: # Lista de regras
    - alert: NginxDown # Nome do alerta
      expr: up{job="nginx"} == 0 # Expressão que será utilizada para disparar o alerta
      for: 1m # Tempo que a expressão deve ser verdadeira para que o alerta seja disparado
      labels: # Labels do alerta
        severity: critical # Label que indica a severidade do alerta
      annotations: # Anotações do alerta
        summary: "Nginx is down" # Título do alerta
        description: "Nginx is down for more than 1 minute. Pod name: {{ $labels.pod }}" # Descrição do alerta
```

Vamos verificar se o alerta foi criado:

```bash
kubectl get prometheusrule -n kube-prometheus-stack 
```

2. **Configurar o Alertmanager**: Em seguida, você precisa configurar o Alertmanager para lidar com os alertas enviados pelo Prometheus. Aqui está um exemplo de como o arquivo `alertmanager-config.yaml` pode parecer:

```yaml
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: 'slack'
receivers:
- name: 'slack'
  slack_configs:
  - send_resolved: true
    username: 'Prometheus'
    channel: '#alerts'
    api_url: 'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXX
```

3. **Configurar o Prometheus para enviar alertas para o Alertmanager**: Por fim, você precisa configurar o Prometheus para enviar alertas para o Alertmanager. Aqui está um exemplo de como o arquivo `prometheus-config.yaml` pode parecer:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - alertmanager.monitoring.svc:9093
rule_files:
  - /etc/prometheus/prometheus-rules.yaml
```

**Atenção** o arquivo `prometheus-config.yaml` é o arquivo de configuração do Prometheus que contém as regras de alerta e a configuração do Alertmanager.

A importância dessas informações estarem corretas é que elas determinam quais alertas serão enviados pelo Prometheus e como esses alertas serão tratados pelo Alertmanager. Se essas informações estiverem incorretas, os alertas podem não ser enviados ou tratados corretamente.
