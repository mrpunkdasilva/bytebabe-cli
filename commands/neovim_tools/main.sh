#!/bin/bash

# ======================
# FERRAMENTAS NEOVIM
# ======================
install_neovim_tools() {
   echo -e "\n${CYBER_BLUE}▶ Instalando Neovim...${RESET}"
   echo -e "${CYBER_YELLOW}Deseja instalar o Neovim e LazyVim? (s/n)${RESET}"
   read -r resposta
   
   if [[ "$resposta" =~ ^[Ss]$ ]]; then
       echo -e "${CYBER_BLUE}Baixando e instalando Neovim...${RESET}"
       
       curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
       sudo rm -rf /opt/nvim
       sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
       rm -f nvim-linux-x86_64.tar.gz

       export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
       export PATH="$PATH:/usr/local/bin"

       echo -e "${CYBER_YELLOW}Deseja instalar LazyVim? (Isso removerá qualquer configuração existente do Neovim) (s/n)${RESET}"
       read -r resposta_lazy
       
       if [[ "$resposta_lazy" =~ ^[Ss]$ ]]; then
           # Remova a instalação anterior
           echo -e "${CYBER_BLUE}Removendo configurações anteriores do Neovim...${RESET}"
           rm -rf ~/.config/nvim
           rm -rf ~/.local/share/nvim
           rm -rf ~/.local/state/nvim

           # Instale novamente
           echo -e "${CYBER_BLUE}Instalando LazyVim...${RESET}"
           git clone https://github.com/LazyVim/starter ~/.config/nvim
       fi

       # Adiciona o caminho ao .bashrc e .zshrc se não existir
       if ! grep -q "/opt/nvim-linux-x86_64/bin" ~/.bashrc; then
           echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
       fi
       
       if [ -f ~/.zshrc ] && ! grep -q "/opt/nvim-linux-x86_64/bin" ~/.zshrc; then
           echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.zshrc
       fi

       # Mensagem final de sucesso
       echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
       echo -e "${CYBER_GREEN}           CONFIGURAÇÃO COMPLETA!"
       echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
       echo -e "${CYBER_BLUE}╭─────────────────────────────────────────────╮"
       echo -e "│ ${CYBER_GREEN}✔ Neovim + LazyVim ${CYBER_BLUE}configurados com sucesso!  "
       echo -e "│                                                         "
       echo -e "│ ${CYBER_YELLOW}Próximos passos:${CYBER_BLUE}                                    "
       echo -e "│ 1. Abra o Neovim: ${CYBER_GREEN}nvim${CYBER_BLUE}                          "
       echo -e "│ 2. Aguarde a instalação automática dos plugins           "
       echo -e "│ 3. Reinicie o Neovim após a conclusão                   "
       echo -e "╰─────────────────────────────────────────────╯${RESET}"
       echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}\n"
   else
       echo -e "${CYBER_YELLOW}Instalação do Neovim ignorada.${RESET}"
   fi
}
