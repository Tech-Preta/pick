# Servidor NFS (Network File System)

O **Servidor NFS** é uma solução que permite compartilhar sistemas de arquivos entre computadores em uma rede. Ele é amplamente usado em ambientes Linux/Unix para compartilhar diretórios e arquivos entre servidores e clientes.

## O que é um servidor NFS?

- **NFS** (Network File System) é um protocolo que permite que um sistema acesse arquivos em outro sistema como se estivessem em seu próprio sistema de arquivos local.
- O servidor NFS exporta (disponibiliza) diretórios ou sistemas de arquivos para os clientes NFS.
- Os clientes NFS montam esses sistemas de arquivos exportados, tornando-os acessíveis como se fossem locais.

## Criando um servidor NFS

Para criar um servidor NFS, siga estas etapas:
0. Crie o diretório que deseja compartilhar:

     ```
     sudo mkdir /mnt/nfs
     ```

1. **Instale o servidor NFS**:
   - Instale o pacote `sudo apt-get install nfs-kernel-server nfs-common` (ou similar) no seu servidor.
   - Inicie e habilite o serviço NFS.

2. **Configure os diretórios a serem exportados**:
   - Edite o arquivo `/etc/exports` para definir os diretórios que deseja compartilhar.
   - Exemplo de linha no arquivo `/etc/exports`:

     ```
     /mnt/nfs *(rw,sync,no_root_squash,no_subtree_check)
     ```

3. **Reinicie o serviço NFS**:
   - Execute o comando para aplicar as alterações:

     ```
     sudo systemctl restart nfs-server
     ```

4. **Configure as regras de firewall**:
   - Abra as portas necessárias (geralmente 2049 para NFS) no firewall do servidor.

5. **Monte o compartilhamento nos clientes**:
   - Nos clientes, use o comando `mount` para montar o compartilhamento NFS:

     ```
     sudo mount servidor:/caminho/do/diretorio /caminho/local
     ```

6. Verifique se o NFS está funcionando corretamente:
   - Use o comando `showmount` para verificar os compartilhamentos exportados:

     ```
     showmount -e 
     ```

A saída deve mostrar os diretórios exportados e os clientes que têm permissão para acessá-los.

```
      Export list for ip-172-31-58-237:
      /mnt/nfs *
```

## Criando um StorageClass do tipo NFS

Para criar um StorageClass do tipo NFS no Kubernetes, você pode usar o seguinte exemplo:

```yaml
apiVersion: storage.k8s.io/v1 
kind: StorageClass 
metadata:
  name: nfs 
provisioner: kubernetes.io/no-provisioner 
reclaimPolicy: Retain 
volumeBindingMode: WaitForFirstConsumer
parameters: 
  archiveOnDelete: "false" 
```

Agora vamos criar volumes que utilizam esse StorageClass:

```yaml
apiVersion: v1 
kind: PersistentVolume 
metadata:
  name: meu-pv-nfs 
  labels:
    storage: nfs 
spec: 
  capacity:
    storage: 1Gi 
  accessModes: 
    - ReadWriteOnce 
  persistentVolumeReclaimPolicy: Retain 
  nfs: 
    server: 3.90.82.216
    path: "/mnt/nfs" 
  storageClassName: nfs  
```

Agora iremos criar um PersistentVolumeClaim (PVC) que utiliza esse PV:

```yaml
apiVersion: v1 
kind: PersistentVolumeClaim 
metadata: 
  name: meu-pvc 
spec: 
  accessModes: 
    - ReadWriteOnce 
  resources: 
    requests: 
      storage: 1Gi 
  storageClassName: nfs 
  selector:
    matchLabels:
      storage: nfs

Agora iremos criar um Pod que utiliza esse PVC:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
    volumeMounts:
    - name: meu-pvc
      mountPath: /usr/share/nginx/html
  volumes:
  - name: meu-pvc
    persistentVolumeClaim:
      claimName: meu-pvc
```

Agora você tem um Pod que utiliza um volume NFS no Kubernetes.
