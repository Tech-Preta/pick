# O que é um Service Monitor? 

No contexto do Prometheus, um "Service Monitor" é um recurso personalizado do Kubernetes que permite ao Prometheus descobrir automaticamente os serviços a serem monitorados. 

1. **Exposição de métricas**: Um endpoint de métricas exposto por uma aplicação em execução em um pod é mapeado para um serviço.
2. **Monitoramento de Serviço**: O endpoint de métricas mapeado para um serviço é exposto pelo serviço a um monitor de serviço.
3. **Descoberta de Serviço**: O operador do Prometheus descobre os endpoints expostos pelo monitor de serviço.
4. **Configuração do Prometheus**: O operador do Prometheus atualiza a configuração do Prometheus para incluir os endpoints expostos pelo monitor de serviço. O Prometheus agora raspará as métricas desses endpoints.

O Service Monitor deve ser configurado com a porta que seu serviço expõe suas métricas (e o caminho para essas métricas nessa porta) e definir o seletor para corresponder ao serviço.

Para configurar um Service Monitor no Prometheus é necessário seguir alguns passos. Aqui está um exemplo de como você pode fazer isso:

1. **Crie um serviço**: Primeiro, você precisa criar um serviço que expõe o endpoint de métricas da sua aplicação. Aqui está um exemplo de como o arquivo `service.yaml` pode parecer:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service
  namespace: application
  labels:
    name:  service
spec:
  ports:
    - name: https
      port: 10443
      protocol: TCP
      targetPort: 10443
    - name:  metrics
      port: 8080
      protocol: TCP
      targetPort: 8080
  selector:
    app: myApplication
```

2. **Crie um Service Monitor**: Em seguida, você precisa criar um Service Monitor que irá descobrir o serviço que você acabou de criar. Aqui está um exemplo de como o arquivo service-monitor.yaml pode parecer:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: service-monitor
  namespace: monitoring
spec:
  endpoints:
    - interval: 30s
      path: /prometheus
      port:  metrics
  namespaceSelector:
    matchNames:
      - application
  selector:
    matchLabels:
      app: myApplication
```

**Atenção** o selector é um campo usado para selecionar os serviços que devem ser monitorados. No exemplo, `matchLabels: app: myApplication` indica que o Service Monitor deve selecionar serviços que têm o label `app: myApplication`.

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
