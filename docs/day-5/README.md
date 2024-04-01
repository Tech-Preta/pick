# Descomplicando networks no Docker

O Docker oferece vários tipos de drivers de rede para atender a diferentes necessidades. Aqui estão os principais:

- **Bridge (Ponte)**: Este é o driver de rede padrão. Quando você cria uma rede sem especificar um driver, ela é do tipo bridge. Redes bridge são comumente usadas quando seus contêineres precisam se comunicar com outros contêineres no mesmo host.

- **Host (Hospedeiro)**: Remove o isolamento de rede entre o contêiner e o host do Docker, permitindo que o contêiner use diretamente a rede do host.

- **Overlay (Sobreposição)**: Redes overlay conectam vários daemons do Docker e permitem que serviços e contêineres do Swarm se comuniquem entre nós. Isso elimina a necessidade de roteamento em nível de sistema operacional1.

- **IPvlan**: Redes IPvlan oferecem controle total sobre os endereços IPv4 e IPv6. O driver VLAN baseia-se nisso, fornecendo controle completo sobre a marcação de VLAN de camada 2 e até mesmo roteamento IPvlan de camada 3 para integração de rede de infraestrutura.

- **Macvla**n: Redes Macvlan permitem atribuir um endereço MAC a um contêiner, fazendo com que ele pareça um dispositivo físico em sua rede. O daemon do Docker roteia o tráfego para os contêineres com base em seus endereços MAC. É útil quando você está migrando de uma configuração de máquina virtual ou quando seus contêineres precisam se parecer com hosts físicos na rede, cada um com um endereço MAC exclusivo.

- **None (Nenhum)**: Isola completamente um contêiner do host e de outros contêineres. O driver none não está disponível para serviços do Swarm.

- **Plugins de Rede**: Você pode instalar e usar plugins de rede de terceiros com o Docker. Esses plugins permitem integrar o Docker com pilhas de rede especializadas.

Em resumo:

1. Bridge: Para contêineres que não exigem capacidades de rede especiais.
2. User-defined bridge: Para comunicação entre contêineres no mesmo host.
3. Host: Compartilha a rede do host com o contêiner.
4. Overlay: Para comunicação entre contêineres em diferentes hosts Docker.
5. Macvlan: Para migração de VMs ou quando os contêineres devem se parecer com hosts físicos.
6. IPvlan: Similar ao Macvlan, mas sem atribuição de MAC exclusivo.

**Plugins de rede: Integração com pilhas de rede personalizadas**. 


## Criação de rede Docker

O comando `docker network create` é usado para criar uma nova rede no Docker. No exemplo fornecido, a rede é chamada de "giropops".

Este comando é útil quando você precisa criar uma rede personalizada para conectar contêineres Docker. As redes Docker permitem que os contêineres se comuniquem entre si, mesmo que estejam em hosts diferentes.

```
docker network create giropops
```

### Criando um rede overlay

```
docker network create -d overlay strigus
```

Erro de resposta do daemon: Este nó não é um gerenciador de swarm. Use "docker swarm init" ou "docker swarm join" para conectar este nó ao swarm e tente novamente.

### Criação de Rede Docker usando o driver macvlan

Este comando cria uma rede Docker usando o driver macvlan. O driver macvlan permite que os contêineres Docker se conectem diretamente à rede física, obtendo um endereço IP da rede externa.


**Opções:**

- `docker network create`: Comando para criar uma rede Docker.

- `-d macvlan`: Opção para especificar o driver macvlan.

- `strigus`: Nome da rede Docker a ser criada.


```
docker network create -d macvlan strigus
```

### Inspecionando uma rede

O comando `docker network inspect` é usado para obter informações detalhadas sobre uma rede Docker específica. Ele exibe informações como o nome da rede, o ID, a data de criação, o driver de rede, as configurações de IP, entre outras informações.

```
docker network inspect 297669d965bf
[
    {
        "Name": "strigus",
        "Id": "297669d965bfb9a7dc0359c8bc8aeecc9420bd0d402d659e1903181aa49d31f5",
        "Created": "2024-04-01T13:48:59.212234154Z",
        "Scope": "local",
        "Driver": "macvlan",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.20.0.0/16",
                    "Gateway": "172.20.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```


### Removendo uma rede

Este comando remove uma rede Docker com o ID especificado. O parâmetro "-f" força a remoção da rede, mesmo que ela esteja sendo usada por algum container.

**Parâmetros:**

- network: O ID ou nome da rede Docker a ser removida.

- -f: Força a remoção da rede, mesmo que ela esteja sendo usada por algum container.

```
docker network rm -f 36abd399b848
```


### Conectando os containers em uma rede

Redis
```
docker run -d --name redis --network giropops-senhas -p 6379:6379 redis
```

Aplicação

```
docker run -d --name giropops-senhas --env REDIS_HOST=172.21.0.2 -p 5000:5000 nataliagranato/linuxtips-giropops-senhas:72c0140-20240328202320
```
Mesmo depois de conectados na mesma rede, a aplicação retornava uma erro 500. Porque até aqui não informamos ao container da aplicação a rede que deve compartilhar com o redis, ambos possuem o mesmo IP.

```
❯ docker inspect e185 | grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "172.17.0.2",
                    "IPAddress": "172.17.0.2",
❯ docker inspect 0750 | grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.21.0.2",
```

A aplicação funcionaria se informassemos o Gateway de rede assim: `docker run -d --name giropops-senhas --env REDIS_HOST=172.21.0.1 -p 5000:5000 nataliagranato/linuxtips-giropops-senhas:72c0140-20240328202320`


Para corrigir o problema devemos iniciar a aplicação com as configurações de rede corretas:

```
docker run -d --name giropops-senhas --network giropops-senhas --env REDIS_HOST=redis -p 5000:5000 nataliagranato/linuxtips-giropops-senhas:72c0140-20240328202320
```

### Conectando containers em uma network temporariamente

O comando `docker network connect` é usado para conectar um container existente a uma rede Docker específica. Ele permite que você adicione um container a uma rede já existente, permitindo a comunicação entre os containers na mesma rede.

```
docker network connect giropops-senhas giropops-senhas
```

O comando `docker network prune` é usado para remover todas as redes Docker não utilizadas. Ele remove todas as redes que não estão sendo usadas por nenhum container em execução.

```
docker network prune
```

**Observação:** Tenha cuidado ao usar este comando, pois ele irá remover permanentemente todas as redes não utilizadas.


## Limitando a utilização de recursos dos containers

Para limitar os recursos dos seus contêineres no Docker, você pode seguir as seguintes opções:

**Limitando memória e CPU na linha de comando:**
Para limitar a memória de um contêiner diretamente na linha de comando, use o seguinte comando:
`docker run -it --memory=256M --cpus=0.5 --name meu_contêiner minha_imagem`

Isso limitará o contêiner a 256 megabytes de memória e 0,5 CPUs (metade de uma CPU).

**Usando o Docker Compose:**
No arquivo docker-compose.yml, você pode definir limitações de recursos para seus contêineres. Por exemplo:
services:
```
  meu_serviço:
    image: minha_imagem
    deploy:
      resources:
        limits:
          cpus: "0.5"
          memory: 256M
```
Isso limitará o contêiner a 0,5 CPUs e 256 megabytes de memória.

Lembre-se de ajustar os valores conforme suas necessidades específicas. Essas limitações ajudam a evitar que os contêineres consumam recursos excessivos e afetem o desempenho do sistema.

**Valide a utilização dos recursos:**

Para verificar se os recursos de CPU e memória estão limitados em um contêiner usando o comando docker container inspect, você pode seguir estas etapas:

**Obtenha o ID ou nome do contêiner:**

Primeiro, você precisa obter o ID ou nome do contêiner que deseja verificar. Você pode usar o comando docker ps para listar todos os contêineres em execução e encontrar o contêiner específico.

Execute o comando docker container inspect:

Use o seguinte comando para inspecionar o contêiner e obter informações detalhadas:
`docker container inspect <nome_ou_id_do_contêiner>`

Substitua <nome_ou_id_do_contêiner> pelo nome ou ID do contêiner específico.

Verifique as seções relevantes:
No resultado do comando, procure pelas seções HostConfig e Config.

Dentro dessas seções, você encontrará informações sobre os limites de CPU e memória definidos para o contêiner.
Por exemplo, se você encontrar algo como:
```
JSON

"HostConfig": {
    "CpuShares": 512,
    "Memory": 536870912
},
```
Isso significa que o contêiner está limitado a 512 unidades de CPU (CpuShares) e 512 megabytes de memória (536870912 bytes).

Lembre-se de que esses valores podem variar dependendo das configurações específicas do seu contêiner. Verifique as seções relevantes no resultado do docker container inspect para obter detalhes específicos sobre os limites de recursos.

Você também pode utilizar o `docker stats <nome_ou_id_do_contêiner>` para exibir estatísticas em tempo real sobre o uso de CPU, memória, E/S e rede de um contêiner específico.