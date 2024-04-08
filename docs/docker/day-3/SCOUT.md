# Docker Scout

À medida que o desenvolvimento de software se torna cada vez mais orientado para containers, a segurança desses containers e das imagens usadas para criá-los ganha importância crítica. As imagens de container são construídas a partir de camadas de outras imagens e pacotes de software. Infelizmente, essas camadas e pacotes podem conter vulnerabilidades que tornam os containers e os aplicativos que eles executam vulneráveis a ataques. Aqui é onde o Docker Scout entra em cena.

## O que é o Docker Scout?

O Docker Scout é uma ferramenta de análise de imagens avançada oferecida pelo Docker. Ele foi projetado para ajudar desenvolvedores e equipes de operações a identificar e corrigir vulnerabilidades em suas imagens de containers. Ao analisar suas imagens, o Docker Scout cria um inventário completo dos pacotes e camadas, também conhecido como Software Bill of Materials (SBOM). Este inventário é então correlacionado com um banco de dados de vulnerabilidades atualizado continuamente para identificar possíveis problemas de segurança.

## Como o Docker Scout funciona?

Você pode usar o Docker Scout de várias maneiras. Ele é integrado ao Docker Desktop e ao Docker Hub, facilitando a análise de imagens durante o processo de construção e implantação. Além disso, ele também pode ser usado em um pipeline de integração contínua, através da interface de linha de comando (CLI) do Docker e no Docker Scout Dashboard.

Para aqueles que hospedam suas imagens no JFrog Artifactory, o Docker Scout também oferece suporte à análise de imagens nesse ambiente.

No CLI do Docker, o Docker Scout oferece vários comandos, incluindo `compare` para comparar duas imagens, `cves` para exibir as vulnerabilidades conhecidas como CVEs identificadas em um artefato de software, `quickview` para uma visão geral rápida de uma imagem e `recommendations` para exibir atualizações de imagens base disponíveis e recomendações de correção.

## Usando o Docker Scout

O comando `docker scout cves` é especialmente importante, pois permite analisar um artefato de software em busca de vulnerabilidades. Este comando suporta a análise de imagens, diretórios OCI layout e arquivos tarball, como os criados pelo comando `docker save`. Isso dá aos desenvolvedores a flexibilidade de verificar a segurança de suas imagens de container de várias maneiras.

## Por que o Docker Scout é importante?

O Docker Scout é uma ferramenta valiosa para melhorar a segurança dos containers. Ao identificar proativamente as vulnerabilidades e fornecer correções recomendadas, ajuda as equipes de desenvolvimento a fortalecer suas imagens de containers e, por sua vez, os aplicativos que estão sendo executados nesses containers. Em um mundo onde a segurança do software é fundamental, o Docker Scout é uma ferramenta indispensável para qualquer equipe de desenvolvimento orientada a containers.
