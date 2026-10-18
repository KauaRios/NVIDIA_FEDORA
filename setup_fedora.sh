#!/usr/bin/env bash
# setup_fedora.sh — atualiza o Fedora e instala o driver NVIDIA via RPM Fusion.
set -Eeuo pipefail

trap 'status=$?; echo; echo "ERRO: a etapa falhou (linha ${LINENO}, código ${status}). Nenhuma etapa posterior será executada." >&2; exit "$status"' ERR

info() { printf '\n\033[1;34m[INFO]\033[0m %s\n' "$*"; }
fail() { printf '\n\033[1;31m[ERRO]\033[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || fail "Execute como usuário normal; o script solicitará sudo quando necessário."
command -v sudo >/dev/null 2>&1 || fail "O comando sudo não está disponível. Instale/configure sudo e execute novamente como usuário autorizado."
[[ -r /etc/os-release ]] || fail "Não foi possível identificar a distribuição."
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == fedora ]] || fail "Este script foi feito para Fedora; sistema detectado: ${PRETTY_NAME:-desconhecido}."
[[ "$(uname -m)" == x86_64 ]] || fail "Este script espera Fedora x86_64; arquitetura detectada: $(uname -m)."
command -v dnf5 >/dev/null 2>&1 || fail "dnf5 não foi encontrado. Este script requer o gerenciador dnf5 do Fedora."
if [[ -e /run/ostree-booted ]]; then
    fail "Fedora Silverblue/Kinoite e outros sistemas rpm-ostree não são suportados por este script."
fi
command -v lspci >/dev/null 2>&1 || fail "O comando lspci não está disponível. Instale pciutils e execute novamente."

if ! lspci -nn | grep -qi nvidia; then
    fail "Nenhum dispositivo NVIDIA foi detectado pelo lspci. Confira se há uma GPU NVIDIA antes de continuar."
fi

FEDORA_VERSION="$(rpm -E %fedora)"
[[ "$FEDORA_VERSION" =~ ^[0-9]+$ ]] || fail "Não foi possível determinar a versão do Fedora."

cat <<'BANNER'
============================================================
 Fedora Setup — atualização e driver NVIDIA (RPM Fusion)
============================================================
Este script irá:
  1. Atualizar o sistema antes de alterar repositórios;
  2. Habilitar RPM Fusion Free e Nonfree;
  3. Atualizar metadados e instalar akmod-nvidia + suporte CUDA;
  4. Tentar compilar o módulo NVIDIA para os kernels instalados.

O computador NÃO será reiniciado automaticamente.
BANNER
read -r -p "Deseja continuar? [s/N] " answer
[[ "$answer" =~ ^([sS]|[sS][iI][mM])$ ]] || { info "Cancelado pelo usuário."; exit 0; }

info "Etapa 1/5: atualizando o sistema antes de mexer nos repositórios..."
sudo dnf5 upgrade --refresh -y

info "Etapa 2/5: habilitando RPM Fusion Free e Nonfree para Fedora ${FEDORA_VERSION}..."
sudo dnf5 install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"

info "Etapa 3/5: atualizando metadados e aplicando atualizações dos novos repositórios..."
sudo dnf5 makecache --refresh
sudo dnf5 upgrade --refresh -y

info "Etapa 4/5: instalando o driver proprietário NVIDIA e suporte CUDA (inclui nvidia-smi)..."
sudo dnf5 install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

info "Etapa 5/5: solicitando a compilação dos módulos NVIDIA para os kernels instalados..."
if command -v akmods >/dev/null 2>&1; then
    sudo akmods --force
else
    info "O comando akmods não foi encontrado; o pacote akmod deve configurar a compilação automática."
fi

printf '\n\033[1;32mConcluído.\033[0m\n'
echo "Versão do Fedora: ${FEDORA_VERSION}"
echo "Kernel em execução: $(uname -r)"
echo
echo "Antes de reiniciar, aguarde alguns minutos para a compilação do módulo terminar."
echo "Depois, reinicie manualmente e verifique com:"
echo "  nvidia-smi"
echo "  modinfo -F version nvidia"
echo
echo "Se o Secure Boot estiver habilitado, o módulo pode exigir configuração/assinatura adicional."
echo "Documentação RPM Fusion: https://rpmfusion.org/Howto/NVIDIA"
