# Instalação do driver NVIDIA no Fedora

Script para Fedora Workstation x86_64 com `dnf5` e GPU NVIDIA. Ele atualiza o sistema, habilita os repositórios RPM Fusion Free e Nonfree, instala `akmod-nvidia` e `xorg-x11-drv-nvidia-cuda`, e solicita a compilação do módulo para os kernels instalados.

## Executar diretamente

Para instalar diretamente do GitHub, copie e execute:

```bash
curl -fL https://raw.githubusercontent.com/KauaRios/NVIDIA_FEDORA/main/setup_fedora.sh -o /tmp/install.sh && bash /tmp/install.sh
```

O script pede confirmação antes de fazer alterações e solicita `sudo` quando necessário. Ele não reinicia o computador. Aguarde a compilação do módulo terminar, reinicie manualmente e confira com `nvidia-smi`.

## Requisitos e observações

- Fedora x86_64 usando `dnf5`; Fedora Silverblue, Kinoite e outros sistemas `rpm-ostree` não são suportados.
- GPU NVIDIA detectável por `lspci` (pacote `pciutils`) e acesso administrativo via `sudo`.
- O Secure Boot pode exigir configuração e assinatura do módulo NVIDIA antes que o driver carregue.
- A execução atualiza o sistema e instala pacotes dos repositórios RPM Fusion. Leia o script antes de executá-lo.

