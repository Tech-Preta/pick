
# Introdução a volumes no Docker

Bom, volumes nada mais são que diretórios externos ao container, que são montados diretamente nele, e dessa forma `bypassam` seu `filesystem`, ou seja, não seguem aquele padrão de camadas que falamos. Decepcionei você? Que bom, sinal de que é bem simples e você não vai ter problemas para entender. :)

A principal função do volume é persistir os dados. Diferentemente do `filesystem` do container, que é volátil e toda informação escrita nele é perdida quando o container morre, quando você escreve em um volume aquele dado continua lá, independentemente do estado do container.

Existem algumas particularidades entre os volumes e containers que valem a pena ser mencionadas:

- O volume é inicializado quando o container é criado.

- Caso ocorra de já haver dados no diretório em que você está montando como volume, ou seja, se o diretório já existe e está "populado" na imagem base, aqueles dados serão copiados para o volume.

- Um volume pode ser reusado e compartilhado entre containers.

- Alterações em um volume são feitas diretamente no volume.

- Alterações em um volume não irão com a imagem quando você fizer uma cópia ou snapshot de um container.

- Volumes continuam a existir mesmo se você deletar o container.

# Volumes do tipo bind

Primeiro, vamos ver como funciona da maneira antiga, que ainda é suportada, porém não é elegante. :)

Essa maneira é muito utilizada quando se quer montar um diretório específico do host dentro do container. Isso é ruim quando estamos trabalhando em cluster, uma vez que teríamos que garantir esse diretório criado em todos os hosts do cluster. Não seria legal.

Porém, podemos aprender como funciona e utilizar em algum momento, caso se faça necessário. Para evitar erros, primeiro crie o diretório "/volume" na sua máquina.

```
root@linuxtips:~# mkdir /volume
root@linuxtips:~# docker container run -ti --mount type=bind,src=/volume,dst=/volume ubuntu
root@7db02e999bf2:/# df -h

Filesystem                  Size  Used Avail Use%   Mounted on
none                         13G  6.8G 5.3G   57%   /
tmpfs                       999M     0 999M    0%   /dev
tmpfs                       999M     0 999M    0%   /sys/fs/cgroup
/dev/mapper/ubuntu--vg-root  13G  6.8G 5.3G   57%   /volume 
shm                          64M     0  64M    0%   /dev/shm

root@7db02e999bf2:/# ls
bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var volume
```

No exemplo anterior, conhecemos um novo parâmetro do comando "docker container run", o "--mount".

O parâmetro "--mount" é o responsável por indicar o volume, que em nosso exemplo é o "/volume", e onde ele será montado no container. Perceba que, quando passamos o parâmetro "--mount type=bind,src=/volume,dst=/volume", o Docker montou esse diretório no container, porém sem nenhum conteúdo.

Podemos também montar um volume no container linkando-o com um diretório do host já com algum conteúdo. Para exemplificar, vamos compartilhar o diretório "/root/primeiro_container", que utilizamos para guardar o nosso primeiro dockerfile, e montá-lo no container em um volume chamado "/volume" da seguinte forma:

```
# docker container run -ti --mount type=bind,src=/root/primeiro_container,dst=/volume ubuntu

root@3d372a410ea2:/# df -h
Filesystem                   Size Used Avail  Use%  Mounted on
none                          13G 6.8G  5.3G   57%  /
tmpfs                        999M    0  999M    0%  /dev
tmpfs                        999M    0  999M    0%  /sys/fs/cgroup
/dev/mapper/ubuntu--vg-root   13G 6.8G  5.3G   57%  /volume
shm                           64M    0   64M    0%  /dev/shm

```

Com isso, estamos montando o diretório "/root/primeiro_dockerfile" do host dentro do container com o nome de "/volume".

No container:

```
root@3d372a410ea2:/# ls /volume/
Dockerfile

```

No host:

```
root@linuxtips:~# ls /root/primeiro_dockerfile/
Dockerfile

root@linuxtips:~#
```

Caso eu queira deixar o volume no container apenas como read-only, é possível. Basta passar o parâmetro "ro" após o destino onde será montado o volume:

```
# docker container run -ti --mount type=bind,src=/root/primeiro_container,dst=/volume,ro ubuntu
root@8d7863b1d9af:/# df -h

Filesystem                   Size   Used  Avail  Use%  Mounted on
none                          13G   6.8G   5.3G   57%  /
tmpfs                        999M      0   999M    0%  /dev
tmpfs                        999M      0   999M    0%  /sys/fs/cgroup
/dev/mapper/ubuntu--vg-root   13G   6.8G   5.3G   57%  /volume
shm                           64M      0    64M    0%  /dev/shm

root@8d7863b1d9af:/# cd /volume/
root@8d7863b1d9af:/volume# ls
Dockerfile

root@8d7863b1d9af:/volume# mkdir teste
mkdir: cannot create directory 'teste': Read-only file system

```

Assim como é possível montar um diretório como volume, também é possível montar um arquivo:

```
# docker container run -ti --mount type=bind,src=/root/primeiro_container/Dockerfile,dst=/Dockerfile ubuntu

root@df0e3e58280a:/# df -h

Filesystem                   Size   Used  Avail  Use%  Mounted on
none                          13G   6.8G   5.3G   57%  /
tmpfs                        999M      0   999M    0%  /dev
tmpfs                        999M      0   999M    0%  /sys/fs/cgroup
/dev/mapper/ubuntu--vg-root   13G   6.8G   5.3G   57%  /Dockerfile
shm                           64M      0    64M    0%  /dev/shm

root@df0e3e58280a:/# cat Dockerfile
FROM debian
RUN /bin/echo "HELLO DOCKER"

root@df0e3e58280a:/#
```

Isso faz com que o arquivo "/root/primeiro_dockerfile/Dockerfile" seja montado em "/Dockerfile" no container.

# Volumes do tipo volume

Agora vamos criar os volumes da maneira mais elegante e atual. Hoje temos a possibilidade de realizar o gerenciamento de volumes de maneira muito simples e inteligente.

Sempre que criamos um volume, ele cria um diretório com o mesmo nome dentro de "/var/lib/docker/volumes/".

No exemplo a seguir, o volume "giropops" seria então criado em "/var/lib/docker/volumes/giropops"; com isso, todos os arquivos disponíveis nesse diretório também estariam disponíveis no local indicado no container. Vamos aos exemplos! :D

É possível fazer a criação de volumes e toda a sua administração através do comando:

```
docker volume create giropops
```

É possível removê-lo através do comando:

```
docker volume rm giropops
```

Para verificar detalhes sobre esse volume:

```
docker volume inspect giropops
```

Para remover os volumes que não estão sendo utilizados (use com extrema moderação! :D):

```
docker volume prune
```

Para que você possa montar o volume criado em algum container/service, basta executar o seguinte comando:

```
docker container run -d --mount type=volume,source=giropops,destination=/var/opa nginx
```

Onde:

**--mount** -- Comando utilizado para montar volumes.

**type=volume** -- Indica que o tipo é "volume". Ainda existe o tipo "bind", onde, em vez de indicar um volume, você indicaria um diretório como source.

**source=giropops** -- Qual o volume que pretendo montar.

**destination=/var/opa** -- Onde no container montarei esse volume.

## Localizando volumes

Caso você queira obter a localização do seu volume, é simples. Mas para isso você precisa conhecer o comando "docker volume inspect".

Com o "docker volume inspect" você consegue obter detalhes do seu `container`, como, por exemplo, detalhes do volume.

A saída do comando "docker volume inspect" retorna mais informação do que somente o `path` do diretório no `host`. Vamos usar a opção "--format" ou "-f" para filtrar a saída do "inspect".

```
docker volume inspect --format '{{ .Mountpoint }}' giropops
/var/lib/docker/volumes/giropopos/_data
```
