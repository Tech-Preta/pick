# Container

Um container é um ambiente isolado contido em um servidor que, diferentemente das máquinas virtuais, divide um único host de controle. Ele é um ambiente isolado utilizado para empacotar aplicações, com o objetivo de segregar e facilitar a portabilidade de aplicações em diferentes ambientes.

## Container Engine

Um Container Engine é uma plataforma que permite criar e executar aplicações em containers. Ele é responsável por tudo, desde a obtenção de imagens de container de um registro até a execução dos containers em seu sistema.

## Container Runtime

O Container Runtime é o software responsável por executar os containers. Ele é responsável por tudo, desde a obtenção de imagens de container de um registro e gerenciamento de seu ciclo de vida até a execução dos containers em seu sistema.

Existem três tipos principais de Container Runtime:

- **Low-level**: Focam mais na execução de containers, configurando o namespace e cgroups para containers.
- **High-level**: Focam em formatos, descompactação, gerenciamento e compartilhamento de imagens. Eles também fornecem APIs para desenvolvedores.
- **Sandbox e Virtualized**: São runtimes que fornecem um ambiente isolado para executar containers.

## OCI - Open Container Initiative

A Open Container Initiative (OCI) é uma estrutura de governança aberta, formada sob os auspícios da Linux Foundation, com o propósito expresso de criar padrões industriais abertos em torno de formatos de container e runtimes. Foi lançada em junho de 2015 pela Docker, CoreOS e outros líderes da indústria de containers.

## O que é o Kubernetes

O Kubernetes, também conhecido como “k8s” , é uma plataforma de código aberto que automatiza os processos de implantação, gerenciamento e dimensionamento de aplicações conteinerizadas. Ele foi inicialmente desenvolvido por engenheiros do Google antes de ser disponibilizado como código aberto em 2014.

## Arquitetura do Kubernetes

![Imagem](https://miro.medium.com/v2/resize:fit:952/1*yq0bky23otUFDU1DbUftGg.png)

A arquitetura do Kubernetes é composta por um conjunto de máquinas físicas ou virtuais, chamadas nós, que executam as cargas de trabalho dos aplicativos. Esses nós são gerenciados por um conjunto de componentes conhecidos como plano de controle (control plane).

### O plano de controle inclui os seguintes componentes

- **API Server (kube-apiserver)**

É o ponto central de coordenação de todo o sistema, expondo a API do Kubernetes via JSON sobre HTTP. Ele processa e valida solicitações REST e atualiza o estado do cluster para refletir a intenção expressa nas solicitações.

- **Scheduler (kube-scheduler)**

É responsável por decidir em qual nó uma carga de trabalho (por exemplo, pods) deve ser executada, com base em vários fatores, como recursos disponíveis, restrições de afinidade/anti-afinidade, etc.

- **Controller Manager (kube-controller-manager)**

Executa uma variedade de controladores de nível de cluster, como o controlador de replicação (que mantém o número correto de pods para cada objeto de replicação no sistema), controladores de endpoints, controladores de namespaces e outros.

- **etcd**

É um banco de dados distribuído e consistente que armazena a configuração do cluster e o estado atual do cluster. É o "banco de dados" para o Kubernetes.

### Cada nó do worker executa dois tipos de componentes

- **Kubelet**

É o agente que se comunica com o plano de controle e garante que os contêineres estejam rodando nos pods conforme o esperado.

- **Kube-proxy**

Mantém as regras de rede nos nós para permitir a comunicação com seus Pods a partir de dentro ou fora do cluster.

- **Container Runtime**

É o software responsável por executar contêineres. Pode ser Docker, containerd, CRI-O, entre outros.

Além disso, os Pods são a menor unidade implantável que podem ser criados e gerenciados no Kubernetes.

### Kubernetes vs Docker

Embora o Docker seja uma plataforma que permite a construção, distribuição e execução de contêineres, o Kubernetes é uma plataforma de orquestração de contêineres para plataformas como o Docker. O Kubernetes e o Docker trabalham em harmonia para criar um ecossistema completo para o desenvolvimento, implantação e gerenciamento conteinerizado.

### Como o Kubernetes surgiu?

O Kubernetes surgiu como um projeto do Google no início dos anos 2000. Naquela época, o Google tinha desenvolvido um sistema de orquestração de aplicativos chamado “Borg System”. Com o surgimento dos contêineres Docker em 2013, vários membros do Projeto Borg do Google decidiram avançar com a ideia e assim surgiu o Kubernetes.

# Kubernetes: Conceitos e Instalação

## Pods, ReplicaSets, Deployments e Services

Os Pods são a menor unidade de um cluster Kubernetes e é onde a sua aplicação será executada. Cada Pod tem seu próprio endereço IP e compartilha um namespace PID, rede e nome de host.

Um ReplicaSet é um processo que executa várias instâncias de um pod e mantém o número especificado de pods constante. Seu objetivo é manter o número especificado de instâncias de Pod em execução em um cluster a qualquer momento para evitar que os usuários percam o acesso ao aplicativo quando um Pod falhar ou estiver inacessível.

Deployments são responsáveis pelo controle de versões no Kubernetes, gerando versões do ReplicaSet.

Services são objetos do Kubernetes que fornecem uma abstração de nível superior para os pods e permitem que os mesmos sejam acessados por outros componentes do cluster.

## Instalando o primeiro cluster com o Kind

Para instalar o Kind, é necessário ter instalados o Docker e o Go. Uma vez instalado, estamos prontos para criar nosso primeiro cluster. Criar um novo cluster é tão fácil quanto rodar o comando `kind create cluster`.

## Conhecendo o YAML e o kubectl com dry-run

O comando `kubectl` com a opção `--dry-run=client -o yaml` permite testar a implantação de um arquivo YAML antes de realmente implantá-lo. Isso simula a implantação do arquivo, exibe a configuração resultante e alerta sobre quaisquer problemas que possam surgir durante a implantação real.

## Explicação das portas

No Kubernetes, o **Control Plane** é composto por vários componentes que **gerenciam o estado do cluster**. As portas de comunicação permitem que os contêineres se comuniquem entre si e com o mundo externo. Aqui estão as portas usadas pelo Control Plane:

- **TCP Inbound** 6443*: Kubernetes API server, usado por todos.
- **TCP Inbound** 2379-2380: etcd server client API, usado pelo kube-apiserver e etcd.
- **TCP Inbound** 10250: Kubelet API, usado pelo kubeadm e pelo Control Plane.
- **TCP Inbound** 10259: kube-scheduler, usado pelo kubeadm.
- **TCP Inbound** 10257: kube-controller-manager, usado pelo kubeadm.

**Os Workers são os nós onde são processados os aplicativos**. Aqui estão as portas usadas pelos Workers:

- **TCP Inbound** 10250: Kubelet API, usado pelo próprio e pelo Control Plane.
- **TCP Inbound** 30000-32767: NodePort, usado por todos os Services.

As portas marcadas com * são customizáveis, você precisa se certificar que a porta alterada também esteja aberta.

### Referências

- [Documentação do Kubernetes - Conceitos de Containers](https://kubernetes.io/pt-br/docs/concepts/containers/)
- [Wiz Academy - Runtimes de Containers](https://www.wiz.io/academy/container-runtimes)
- [Open Containers Initiative](https://opencontainers.org/)
- [Kubernetes - Site Oficial](https://kubernetes.io/)
- [Artigo Comparativo entre Kubernetes e Docker](https://www.itprotoday.com/containers/kubernetes-vs-docker-what-s-difference)
- [História do Kubernetes](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)
- [An Introduction to Kubernetes (DigitalOcean)](https://www.digitalocean.com/community/tutorials/an-introduction-to-kubernetes)
- [What is Kubernetes? (Red Hat)](https://www.redhat.com/en/topics/containers/what-is-kubernetes)
