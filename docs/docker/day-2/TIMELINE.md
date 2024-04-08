# Timeline: Criação de uma Imagem Docker

- **Criação do Dockerfile**: O primeiro passo na criação de uma imagem Docker é criar um arquivo chamado Dockerfile. Esse arquivo contém as instruções necessárias para construir a imagem, como a escolha da base, a instalação de dependências e a configuração do ambiente.

- **Build da Imagem**: Após a criação do Dockerfile, é necessário executar o comando docker build para iniciar o processo de construção da imagem. Nesse momento, o Docker irá ler o arquivo Dockerfile e compilar a imagem conforme as instruções especificadas.

- **Tag da Imagem**: Após a conclusão do build, é possível adicionar tags à imagem para facilitar sua identificação e versionamento. Por exemplo, podemos adicionar uma tag indicando a versão da aplicação ou o ambiente de destino.

- **Push da Imagem**: Para disponibilizar a imagem em um repositório remoto, é necessário utilizar o comando docker push. Esse comando envia a imagem para um registro, como o Docker Hub ou um registro privado, permitindo que outras pessoas possam baixar e utilizar a imagem.

- **Verificação de Vulnerabilidades**: É importante garantir a segurança da imagem antes de disponibilizá-la para uso. Para isso, podemos utilizar ferramentas de verificação de vulnerabilidades, como o Trivy. Essas ferramentas analisam a imagem em busca de componentes com falhas de segurança conhecidas.

- **Assinatura com o Cosign**: Para adicionar uma camada extra de segurança, é possível assinar digitalmente a imagem utilizando o Cosign. Essa assinatura garante a integridade da imagem, permitindo que os usuários verifiquem a autenticidade e a procedência da mesma.

Esses são os principais marcos na criação de uma imagem Docker, desde a criação do Dockerfile até a assinatura com o Cosign. Cada passo é essencial para garantir a qualidade, segurança e confiabilidade da imagem.
