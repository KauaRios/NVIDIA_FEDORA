# Instalação do driver NVIDIA no Fedora

Script para Fedora Workstation x86_64 com `dnf5` e GPU NVIDIA. Ele atualiza o sistema, habilita os repositórios RPM Fusion Free e Nonfree, instala `akmod-nvidia` e `xorg-x11-drv-nvidia-cuda`, e solicita a compilação do módulo para os kernels instalados.

## Executar diretamente

Depois de criar este repositório no GitHub, substitua `SEU_USUARIO` e `NOME_DO_REPOSITORIO` pelo usuário/organização e nome usados no GitHub. Copie e execute:

```bash
curl -fL https://raw.githubusercontent.com/SEU_USUARIO/NOME_DO_REPOSITORIO/main/setup_fedora.sh -o /tmp/install.sh && bash /tmp/install.sh
```

O script pede confirmação antes de fazer alterações e solicita `sudo` quando necessário. Ele não reinicia o computador. Aguarde a compilação do módulo terminar, reinicie manualmente e confira com `nvidia-smi`.

## Requisitos e observações

- Fedora x86_64 usando `dnf5`; Fedora Silverblue, Kinoite e outros sistemas `rpm-ostree` não são suportados.
- GPU NVIDIA detectável por `lspci` (pacote `pciutils`) e acesso administrativo via `sudo`.
- O Secure Boot pode exigir configuração e assinatura do módulo NVIDIA antes que o driver carregue.
- A execução atualiza o sistema e instala pacotes dos repositórios RPM Fusion. Leia o script antes de executá-lo.

## Criar o repositório no GitHub

Crie um repositório vazio no GitHub e, nesta pasta, configure o endereço remoto e envie os arquivos:

```bash
git init
git add setup_fedora.sh README.md
git commit -m "Adiciona instalador do driver NVIDIA para Fedora"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/NOME_DO_REPOSITORIO.git
git push -u origin main
```

Troque os mesmos valores de usuário e repositório antes de executar os comandos.
