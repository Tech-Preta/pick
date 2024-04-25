# Criando um Cluster Kubernetes em Instâncias EC2

Este guia detalha o processo de criação de um cluster Kubernetes em instâncias EC2 na AWS, com base nas configurações e comandos fornecidos.

## Configurações das Instâncias EC2

* **Nome**: k8s
* **Número de Instâncias**: 5
* **Imagem da Máquina**: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
* **Arquitetura**: 64 bits (x86)
* **Tipo de Instância**: t2.medium
* **Key Pair**: key_par_k8s
* **Configuração de Armazenamento**: Volume do tipo gp3

## Configurações do Cluster Kubernetes

Para criar um cluster Kubernetes usando o kubeadm, é necessário liberar algumas portas no grupo de segurança das instâncias EC2. Essas portas são essenciais para o funcionamento correto do cluster. A seguir, estão as portas que precisam ser liberadas:

* **Porta 6443**: Essa porta é usada pelo servidor de API do Kubernetes para comunicação com os componentes do cluster. É necessário permitir o tráfego TCP na porta 6443 para que os nós do cluster possam se comunicar com o servidor de API.

* **Portas 10250-10259**: Essas portas são usadas pelo kubelet, kube-scheduler e kube-controller-manager para comunicação interna no cluster. É necessário permitir o tráfego TCP nessas portas para que os componentes do cluster possam se comunicar entre si.

* **Porta 30000-32767**: Essas portas são usadas para serviços NodePort no Kubernetes. É necessário permitir o tráfego TCP nessas portas para que os serviços NodePort possam ser acessados externamente.

* **Portas 6783-6784**: Essas portas são usadas pelo Weave Net para comunicação interna no cluster. É necessário permitir o tráfego UDP nessas portas para que o Weave Net possa funcionar corretamente.

* **Portas 2379-2380**: Essas portas são usadas pelo etcd para comunicação interna no cluster. É necessário permitir o tráfego TCP nessas portas para que o etcd possa funcionar corretamente.

Além disso, é importante lembrar de liberar a porta 22 para permitir a conexão SSH com as instâncias EC2.

Certifique-se de configurar corretamente as regras de entrada no grupo de segurança das instâncias EC2 para permitir o tráfego nessas portas. As regras de saída podem ser mantidas com as configurações padrão da AWS.
TCP - Portas 10250-10259 - Security Group ID - Kubelet API, kube-scheduler e kube-controller-manager.

**Regras de Saída**:

Não irei específicar as regras de saída, portanto, usarão as configurações padrão da AWS.

## Conectando-se às Instâncias

Para se conectar às instâncias EC2, é necessário usar a chave privada associada ao key pair usado durante a criação das instâncias. A seguir, está o comando para se conectar a uma instância EC2 usando a chave privada:

```bash
sudo chmod 400 sua_chave_privada.pem
ssh -i "sua_chave_privada.pem" ubuntu@ip_da_instância.compute-1.amazonaws.com
```

Substitua `sua_chave_privada.pem` pelo caminho da sua chave privada e `ip_da_instância.compute-1.amazonaws.com` pelo endereço IP público da instância EC2.

Altere o hostname da máquina:

```bash
sudo su -
hostnamectl set-hostname k8s-1
```

## Configurando os Nós

1. Desativando a Memória Swap:

```bash
sudo swapoff -a
```

Este comando desativa a memória swap em seu sistema. No contexto do Kubernetes, a memória swap pode interferir no desempenho do sistema e causar problemas de estabilidade, portanto, é recomendado desativá-la.

2. Configurando os Módulos de Kernel:

```bash
sudo nano /etc/modules-load.d/k8s.conf
```

Este comando abre o editor de texto nano para editar o arquivo k8s.conf localizado no diretório /etc/modules-load.d/. Este arquivo é usado para especificar quais módulos do kernel devem ser carregados durante a inicialização do sistema.

Adicione as seguintes linhas ao arquivo:

```bash
br_netfilter
overlay
```

Esses módulos do kernel são necessários para o funcionamento adequado do Kubernetes. O br_netfilter é usado para configurar a ponte de rede do Docker, enquanto o overlay é usado para suportar a camada de sobreposição de contêineres.

Salve e feche o arquivo.

3. Carregando os Módulos de Kernel:

```bash
sudo modprobe br_netfilter
sudo modprobe overlay
```

4. Em seguida, execute:

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

Estes comandos são usados para configurar os parâmetros do sistema no Linux, especialmente para preparar o ambiente para a execução do Kubernetes.

* `cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf`: Este comando redireciona a entrada para um arquivo chamado `k8s.conf` localizado no diretório `/etc/sysctl.d/`. O conteúdo que vem após `<<EOF` é inserido neste arquivo. Neste caso, estamos definindo três parâmetros do sistema relacionados ao funcionamento do Kubernetes:

  * `net.bridge.bridge-nf-call-iptables  = 1`: Habilita a chamada do iptables para encaminhamento de pacotes entre interfaces de rede.
  * `net.bridge.bridge-nf-call-ip6tables = 1`: Habilita a chamada do ip6tables para encaminhamento de pacotes IPv6 entre interfaces de rede.
  * `net.ipv4.ip_forward                 = 1`: Habilita o encaminhamento de IP no sistema, permitindo que os pacotes sejam roteados entre diferentes interfaces de rede.

  O `EOF` indica o fim do texto que será redirecionado para o arquivo.

* `sudo sysctl --system`: Este comando é usado para recarregar as configurações do sistema sem precisar reiniciar. Isso faz com que o sistema leia e aplique as configurações definidas no arquivo `k8s.conf` e em outros arquivos de configuração no diretório `/etc/sysctl.d/`.

5. Instalando kubectl, kubeadm e kubelet:

```bash
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

6. Instalando e configurando o Containerd:

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL <https://download.docker.com/linux/ubuntu/gpg> -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

1. `sudo apt-get update`: Atualiza a lista de pacotes disponíveis e suas versões, mas não instala ou atualiza nenhum pacote.

2. `sudo apt-get install ca-certificates curl`: Instala os pacotes `ca-certificates` e `curl`. `ca-certificates` é usado para verificar a confiabilidade dos servidores remotos, e `curl` é usado para baixar dados de ou para um servidor.

3. `sudo install -m 0755 -d /etc/apt/keyrings`: Cria o diretório `/etc/apt/keyrings` com permissões `0755`.

4. `sudo curl -fsSL <https://download.docker.com/linux/ubuntu/gpg> -o /etc/apt/keyrings/docker.asc`: Baixa a chave GPG do repositório Docker e a salva no arquivo `/etc/apt/keyrings/docker.asc`.

5. `sudo chmod a+r /etc/apt/keyrings/docker.asc`: Altera as permissões do arquivo `docker.asc` para que todos os usuários possam lê-lo.

6. O comando `echo` cria uma nova entrada na lista de fontes do APT para o repositório Docker.

7. `sudo apt-get update`: Novamente, atualiza a lista de pacotes disponíveis e suas versões.

8. `sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`: Instala o Docker, o CLI do Docker, o Containerd, o plugin Docker Buildx e o plugin Docker Compose.

7. Configurando o Containerd:

```bash

sudo containerd config default | sudo tee /etc/containerd/config.toml


sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl status containerd
```

8. Habilitando o serviço do Kubelet:

```bash
sudo systemctl enable --now kubelet
systemctl status kubelet
```

**Nota**: A partir daqui, execute os comandos como `root` para evitar problemas de permissões, erros de certificado, etc.

# Criando o cluster Kubernetes na versão v1.30

1. Inicializando o cluster:

```bash
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=<ip-controlplane>

# Configurando o Acesso ao Kubernetes:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

2. Adicionando nós workers ao cluster:

```bash
sudo kubeadm join <ip-controlplane:6443> --token <token> --discovery-token-ca-cert-hash  sha256:<hash>
```

3. Instalando o Wave Net para a rede do cluster:

```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

4. Verificando o status do cluster:

```bash
kubectl get nodes
kubectl get pods -A
```

Agora você tem um cluster Kubernetes funcional em execução em instâncias EC2 na AWS. Você pode implantar aplicativos, serviços e recursos no cluster e começar a explorar as capacidades do Kubernetes.
