# O que são volumes e seus tipos

Volumes no Docker são um componente crucial do ecossistema que armazena e gerencia dados persistentes gerados por contêineres efêmeros. Eles permitem que os dados persistam mesmo após a remoção ou atualização de um contêiner, evitando que dados essenciais do aplicativo sejam perdidos durante operações de rotinas.

- Bind-mounts: São montagens de diretório do sistema host para um contêiner. Você precisa vincular as montagens de associação a um diretório específico no sistema host.

- Volume-volume: São volumes criados e gerenciados pelo Docker

- tmpfs: O tmpfs é um sistema de arquivos baseado em memória que permite armazenar dados de forma temporária na memória RAM. No Docker, quando você cria um contêiner com uma montagem tmpfs, o contêiner pode criar arquivos fora da camada gravável do contêiner. Ao contrário dos volumes e das montagens de associação, uma montagem tmpfs é temporária e persiste apenas na memória do host. Quando o contêiner para, a montagem tmpfs é removida e os arquivos escritos lá não serão persistidos. **Isso é útil para armazenar temporariamente arquivos sensíveis que você não deseja persistir** nem na camada gravável do host nem do contêiner.

## Criando um volume do tipo bind

Para criar um volume do tipo bind, siga estes passos:

1. Crie um diretório na máquina hospedeira onde você deseja armazenar o volume. Neste exemplo, o diretório é criado usando o comando `sudo mkdir /volume`.

2. Execute um container Docker com a flag `--mount` para especificar o tipo de volume como `bind`. O parâmetro `src` especifica o caminho do diretório na máquina hospedeira, e o parâmetro `dst` especifica o caminho do diretório dentro do container. Neste exemplo, o comando é `docker container run -ti --mount type=bind,src=/volume,dst=/volume ubuntu`.

## Criando e gerenciando um volume do tipo volume

1. Listando os volumes: `docker volume ls`.

2. Criando um volume: `docker volume create giropops`.

3. Removendo um volume: `docker volume rm giropops`.

4. Obtendo detalhes do volume: `docker volume inspect giropops`.

5. Localizando o diretório dos volumes: `cd /var/lib/docker/volumes/`.

6. Removendo volumes não-utilizados: `docker volume prune`.

7. Montando um volume criado em algum container: `docker container run -d --mount type=volume,source=giropops,destination=/var/opa nginx`.

8. Containers utilizando o mesmo volume: `docker run -d --name testando-volumes-1 --mount type=volume,source=giropops,target=/giropops debian`.

9. Localizando volumes: `docker volume inspect --format '{{ .Mountpoint }}' giropops`.

## Outras formas de montar volumes e storage drivers

Os drivers de armazenamento no Docker controlam como as imagens e os contêineres são armazenados e gerenciados no seu host Docker. O Docker suporta vários drivers de armazenamento, usando uma arquitetura plugável. Aqui estão alguns dos drivers de armazenamento disponíveis:

1. **overlay2**: É o driver de armazenamento preferido para todas as distribuições Linux atualmente suportadas e não requer nenhuma configuração extra.

2. **fuse-overlayfs**: É preferido apenas para a execução do Docker sem raiz em um host que não oferece suporte para overlay2 sem raiz.

3. **btrfs e zfs**: Esses drivers de armazenamento permitem opções avançadas, como a criação de “snapshots”, mas requerem mais manutenção e configuração.

4. **vfs**: O driver de armazenamento vfs é destinado a fins de teste e para situações em que nenhum sistema de arquivos com cópia na gravação pode ser usado.

5. **aufs**: Era o driver preferido para versões anteriores do Docker, quando executado em uma versão anterior do Ubuntu.

6. **devicemapper**: Requer direct-lvm.

Cada driver de armazenamento tem suas próprias vantagens e desvantagens, e a escolha do driver de armazenamento a ser usado depende das necessidades específicas do seu aplicativo.

## Criando um volume do tipo tmpfs

```
docker container run -d --mount type=tmpfs,target=/strigus -p 8081:80 nginx 
```

Este comando executa um contêiner Docker com a imagem do Nginx e configura um volume temporário (tmpfs) montado no diretório "/strigus". O contêiner é executado em segundo plano (-d) e expõe a porta 8081 do host para a porta 80 do contêiner (-p 8081:80).

### Volume Temporário (tmpfs)

O volume temporário (tmpfs) é um tipo de volume no Docker que é armazenado na memória RAM em vez de ser armazenado no disco. Ele é útil para armazenar dados temporários que não precisam ser persistentes entre as reinicializações do contêiner.

Ao usar um volume temporário, os dados são gravados diretamente na memória RAM, o que proporciona um acesso mais rápido aos dados. No entanto, é importante ter em mente que os dados armazenados em um volume temporário serão perdidos quando o contêiner for reiniciado ou desligado.

No exemplo acima, o volume temporário é montado no diretório "/strigus" dentro do contêiner. Qualquer dado gravado nesse diretório será armazenado na memória RAM e será perdido quando o contêiner for reiniciado ou desligado.

Para mais informações sobre volumes no Docker, consulte a documentação oficial: [Docker Volumes](https://docs.docker.com/storage/volumes/)
