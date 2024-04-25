# Volumes no Kubernetes

Os volumes no Kubernetes oferecem uma maneira de persistir e compartilhar dados entre os containers de um pod. Eles permitem que os dados sobrevivam à vida do contêiner e possam ser acessados por outros contêineres no mesmo pod. Os volumes são montados em um diretório específico dentro do sistema de arquivos do contêiner.

## O que é um StorageClass?

O StorageClass é um recurso do Kubernetes que fornece uma maneira de definir diferentes classes de armazenamento para os volumes persistentes (PVs - Persistent Volumes) que serão provisionados dinamicamente. Ele atua como uma abstração entre os administradores de cluster e os usuários que solicitam armazenamento.

## Os tipos de StorageClass

Existem diferentes tipos de StorageClass que podem ser definidos com base nas necessidades específicas de armazenamento de uma aplicação:

## PV (Persistent Volume)

Um Persistent Volume (PV) é um recurso no Kubernetes que representa um volume de armazenamento persistente em um cluster. Ele é provisionado manualmente por um administrador do cluster ou dinamicamente por um StorageClass. Um PV tem um ciclo de vida independente do pod que o utiliza, o que significa que os dados persistem mesmo que o pod seja excluído.

## PVC (Persistent Volume Claim)

Um Persistent Volume Claim (PVC) é um recurso usado por um pod para solicitar armazenamento persistente de um PV. Os PVCs são vinculados a um PV que atende aos requisitos de armazenamento definidos no PVC. Quando um PVC é criado, o Kubernetes procura um PV disponível que atenda aos critérios especificados no PVC e o vincula automaticamente.

Por meio da combinação de PVs e PVCs, os desenvolvedores podem provisionar e utilizar armazenamento persistente de forma dinâmica e escalável em um cluster Kubernetes, sem a necessidade de gerenciamento manual por parte dos administradores. Isso oferece flexibilidade e eficiência na utilização de recursos de armazenamento dentro de um ambiente de contêineres.

## Políticas de retenção de volumes no Kubernetes

No Kubernetes, as políticas de retenção de volumes são definidas para determinar o que acontece com um volume quando ele não é mais necessário. Atualmente, as políticas de retenção são:

- **Retain**: Com essa política, quando um PersistentVolumeClaim (PVC) é excluído, o PersistentVolume (PV) correspondente não é excluído. Em vez disso, ele é movido para o estado “Released” e os dados no volume são mantidos. A recuperação dos dados é manual neste caso.

- **Recycle**: Esta política está depreciada e será removida em uma futura versão do Kubernetes1. Anteriormente, ela permitia a limpeza básica do volume (por exemplo, rm -rf /thevolume/*) antes de ser reutilizado.

- **Delete**: Com essa política, quando um PVC é excluído, o PV correspondente e os dados associados também são excluídos. Isso é feito automaticamente pelo cluster Kubernetes.

## Modos de acesso a volumes no Kubernetes

Os três modos de acesso a volumes disponíveis no Kubernetes são:

- **ReadWriteOnce (RWO)**: O volume pode ser montado como leitura-gravação por um único nó.

- **ReadOnlyMany (ROX)**: O volume pode ser montado como somente leitura por muitos nós.

- **ReadWriteMany (RWX)**: O volume pode ser montado como leitura-gravação por muitos nós.

Esses modos de acesso determinam como o volume pode ser acessado quando é montado em um Pod. Por exemplo, se um volume for montado com o modo de acesso `ReadWriteOnce`, ele só poderá ser montado por um único nó para leitura e gravação. Se o mesmo volume for montado por outro nó, a montagem falhará. Por outro lado, um volume com o modo de acesso `ReadWriteMany` pode ser montado por vários nós para leitura e gravação simultaneamente.

## Exemplo de uso de volumes no Kubernetes

A seguir, um exemplo de como definir um volume persistente em um pod no Kubernetes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
    containers:
    - name: mycontainer
        image: nginx
        volumeMounts:
        - mountPath: /usr/share/nginx/html
        name: myvolume
    volumes:
    - name: myvolume
        persistentVolumeClaim:
        claimName: myclaim
```

Neste exemplo, um volume persistente chamado `myvolume` é montado no diretório `/usr/share/nginx/html` do contêiner `mycontainer`. O volume é associado a um PersistentVolumeClaim (PVC) chamado `myclaim`, que define os requisitos de armazenamento necessários para o volume.
