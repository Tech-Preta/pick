
# Simulando o sistema de arquivos do Debian

O debootstrap é uma ferramenta que instala um sistema base Debian em um subdiretório de outro sistema já instalado. Ele não requer um CD de instalação, apenas acesso a um repositório Debian. Além disso, o debootstrap pode ser instalado e executado a partir de outro sistema operacional. Por exemplo, você pode usar o debootstrap para instalar o Debian em uma partição não utilizada de um sistema Gentoo em execução.

## Primeiro, instale o debootstrap

```
apt-get install debootstrap -y
```

### Em seguida, execute o debootstrap

```
debootstrap stable /debian
```

O comando debootstrap stable /debian instala um sistema base Debian estável no diretório /debian do sistema atual.

Ele faz isso baixando os pacotes necessários do repositório Debian e instalando-os no diretório especificado. *Este comando é útil para criar um ambiente chroot, ou para instalar o Debian em uma partição não utilizada de outro sistema*.

## Simulando o funcionamento de Containers

1. Para utilizar os namespaces, execute o seguinte comando:

```
unshare --mount --uts --ipc --net --map-root-user --pid --fork chroot /debian /bash
```

* `unshare`: Este comando cria novos espaços de nomes (namespaces), que são usados para isolar recursos do sistema1.

* `--mount`: Cria um novo espaço de nomes de montagem. Isso significa que as alterações feitas no sistema de arquivos não afetarão o restante do sistema1.

* `--uts`: Cria um novo espaço de nomes UTS, o que significa que alterações no hostname ou no nome de domínio não afetarão o restante do sistema1.

* `--ipc`: Cria um novo espaço de nomes IPC, proporcionando ao processo um espaço de nomes independente para filas de mensagens POSIX e System V, conjuntos de semáforos e segmentos de memória compartilhada1.

* `--net`: Cria um novo espaço de nomes de rede, fornecendo ao processo pilhas IPv4 e IPv6 independentes, tabelas de roteamento IP, regras de firewall, etc1.

* `--map-root-user`: Mapeia o usuário atual para o usuário root dentro do novo espaço de nomes2.

* `--pid`: Cria um novo espaço de nomes PID, o que significa que os processos filhos terão um conjunto distinto de mapeamentos PID para processo em relação ao seu pai.

* `--fork`: Faz com que o unshare crie um novo processo filho.

* `chroot /debian`: Altera a raiz do sistema de arquivos para o diretório /debian.

* `/bash`: Executa o comando /bash dentro do novo ambiente isolado.

Portanto, este comando é útil para criar um ambiente isolado para testes ou depuração, onde as alterações feitas não afetarão o sistema principal.

1. Monte o sistema de arquivos proc:

```
mount -t proc proc /proc
```

1. Verifique os processos em execução:

```
ps -ef
```

Nesse momento, simulamos o funcionamento do container com os isolamentos. Com o ps -ef, vemos com clareza a execução de somente dois processos.

1. Monte os sistemas de arquivos sysfs e tmp:

```
mount -t sysfs none /sysfs

mount -t tmp none /tmp
```

### Cgroups - Grupos de controle

O `cgroups` é um recurso do kernel do Linux que permite limitar, contabilizar e isolar o uso de recursos por grupos de tarefas (processos) em execução em um sistema.

* `Limitar Recursos`: Você pode configurar um cgroup para limitar quanto de um determinado recurso (como memória ou CPU) um processo pode usar3.

* `Contabilizar Recursos`: O cgroups permite monitorar o uso de recursos por processos1.

* `Isolar Recursos`: O cgroups fornece isolamento de recursos, garantindo que os processos em um cgroup não sejam afetados pelo uso de recursos em outros cgroups1.

**Os cgroups são um componente-chave dos containers porque geralmente há vários processos em execução em um container que precisam ser controlados juntos**. Portanto, o cgroups é extremamente importante para o ajuste de desempenho de um sistema Linux.

1. Instale as ferramentas de cgroup:

sudo apt install cgroup-tools -y

2. Crie grupos de controle:

```
sudo cgcreate -g cpu,memory,blkio,devices,freezer:giropops
```

3. Verifique se o grupo giropops tem controle sobre a CPU:

```
ls /sys/fs/cgroup/cpu/giropops
```

4. Classifique os grupos:

```
sudo cgclassify -g cpu,memory,blkio,devices,freezer:giropops
```

5. Limite os recursos do grupo:

```
sudo cgset -r cpu.cfs_quota_us=1000 giropops
```

### Copy on Write ou simplesmente CoW

É uma técnica fundamental usada em containers, como Docker, para otimizar o uso de armazenamento e desempenho. Funciona da seguinte forma:

* `Eficiência de Armazenamento`: Quando você tem uma ou mais cópias dos mesmos dados, o CoW é uma técnica simples baseada em ponteiros para armazenamento eficiente. Em vez de copiar todos os bytes para um novo diretório (um processo demorado e que consome disco), o CoW cria apenas um conjunto de ponteiros no novo diretório - um ponteiro para cada arquivo.

* `Desempenho de Cópia`: Todas as operações de leitura para os arquivos no novo diretório abrirão os mesmos bytes apontados no diretório original. Se um usuário deseja modificar um dos arquivos no novo diretório, uma cópia real de seus bytes é feita nesse momento antes de permitir que o usuário faça as edições.

* `Modificação de Arquivos`: Quando um arquivo em uma camada somente leitura (não a camada superior) é modificado, o arquivo inteiro é primeiro copiado da camada somente leitura para a camada gravável antes que a alteração seja feita. **Isso é chamado de Copy on Write**.

Essas características do CoW permitem que uma única imagem Docker seja usada de maneira eficiente por vários containers e também para iniciar novos containers rapidamente.

### Instalando e começando a usar o Docker

1. Execute o seguinte comando para instalar o Docker:

```
curl -fsSL <https://get.docker.com/> | sh
```

2. Execute o seu primeiro container:

```
docker container run hello-world
```

3. Para algo mais ambicioso, você pode executar um container Ubuntu com:

```
docker run -it ubuntu bash
```

Os parâmetros -i e -t são usados para controlar a interação com o container:

* `-i (ou --interactive)`: Este parâmetro mantém o STDIN aberto mesmo sem um console anexado, permitindo a interação com o container.

* `-t (ou --tty)`: Este parâmetro aloca um pseudo-TTY ou terminal, que permite que você interaja com o container como se estivesse em um terminal de comando.
Juntos, -it, permitem que você inicie um container e interaja com ele através de um terminal.

4. Liste todos os containers:

```
docker container ls -a
```

5. Execute um container Centos:

```
docker container run -ti centos:7
```

Para sair do container sem matar seu entrypoint "o processo principal", utilize o ctrl e p+q ao mesmo tempo para que ele continue em execução.

Para voltar novamente para o container, utilize o seguinte comando:

```
docker container attach <CONTAINER ID>
```

6. Criando um container sem inicializá-lo:

```
docker container create -ti ubuntu
```

Para executar o container recem criado, basta utilizar o "docker container start [CONTAINER ID]".

7. Parando um Container sem Matá-lo

```
docker container stop [CONTAINER ID]
```

8. Reinicie um container:

```
docker container restart [CONTAINER ID]
```

9. Despause um container:

```
docker container unpause [CONTAINER ID]
```

10. Veja as estatísticas de um container:

```
docker container stats [CONTAINER ID]
```

11. Para exibir os logs de forma dinâmica, ou seja, conforme aparecem novas mensagens ele atualiza a saída no terminal, utilizamos a opção "-f":

```
docker container logs -f [CONTAINER ID]
```

12. Quando removemos um container, a imagem que foi utilizada para a sua criação permanece no host; somente o container é apagado.

```
docker container rm [CONTAINER ID]
```
