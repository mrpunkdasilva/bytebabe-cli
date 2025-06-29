#!/bin/bash

# Cores para melhor visualização
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para um editor de texto simples
byte_edit() {
    local file=$1

    if [ -z "$file" ]; then
        echo -e "${RED}Especifique o arquivo para editar!${NC}"
        echo -e "Uso: $0 <arquivo>"
        return 1
    fi

    # Verifica se o arquivo existe, se não, cria
    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}Arquivo '$file' não existe. Criando novo arquivo...${NC}"
        touch "$file"
    fi

    # Carrega o conteúdo do arquivo
    local lines=()
    if [ -s "$file" ]; then
        while IFS= read -r line; do
            lines+=("$line")
        done < "$file"
    fi

    # Se o arquivo estiver vazio, adiciona uma linha vazia
    if [ ${#lines[@]} -eq 0 ]; then
        lines+=("")
    fi

    # Variáveis para o editor
    local current_line=0
    local running=true
    local modified=false

    # Função para exibir o conteúdo
    display_content() {
        clear
        echo -e "${BLUE}=== ByteEdit - $file (Linhas: ${#lines[@]}) ===${NC}"
        echo -e "${YELLOW}Comandos: q (sair), w (salvar), n (nova linha), d (deletar linha), e (editar linha)${NC}"
        echo -e "${YELLOW}          j/+ (baixo), k/- (cima), g (ir para linha), h (ajuda)${NC}"
        echo ""

        # Exibe o conteúdo com números de linha
        for i in "${!lines[@]}"; do
            local line_num=$((i + 1))
            local marker=" "

            if [ $i -eq $current_line ]; then
                marker=">"
                echo -e "${GREEN}$line_num $marker ${lines[$i]}${NC}"
            else
                echo -e "$line_num $marker ${lines[$i]}"
            fi
        done

        echo ""
        echo -e "${GREEN}Linha atual: $((current_line + 1))${NC}"
    }

    # Loop principal do editor
    while $running; do
        display_content

        # Lê o comando do usuário
        read -p "Comando: " cmd

        case "$cmd" in
            q)
                # Sair do editor
                if $modified; then
                    read -p "Arquivo modificado. Salvar antes de sair? (s/n): " save_before_exit
                    if [[ "$save_before_exit" == "s" ]]; then
                        # Salva o arquivo
                        printf "%s\n" "${lines[@]}" > "$file"
                        echo -e "${GREEN}Arquivo salvo.${NC}"
                    fi
                fi
                running=false
                ;;
            w)
                # Salvar o arquivo
                printf "%s\n" "${lines[@]}" > "$file"
                echo -e "${GREEN}Arquivo salvo.${NC}"
                modified=false
                read -n 1 -p "Pressione qualquer tecla para continuar..."
                ;;
            n)
                # Adicionar nova linha após a atual
                read -p "Digite o texto da nova linha: " new_line
                lines=("${lines[@]:0:$((current_line+1))}" "$new_line" "${lines[@]:$((current_line+1))}")
                current_line=$((current_line + 1))
                modified=true
                ;;
            d)
                # Deletar linha atual
                if [ ${#lines[@]} -gt 1 ]; then
                    lines=("${lines[@]:0:$current_line}" "${lines[@]:$((current_line+1))}")
                    if [ $current_line -ge ${#lines[@]} ]; then
                        current_line=$((${#lines[@]} - 1))
                    fi
                    modified=true
                else
                    # Se for a última linha, limpa-a em vez de remover
                    lines[0]=""
                    modified=true
                fi
                ;;
            e)
                # Editar linha atual
                read -p "Editar linha $((current_line + 1)) [${lines[$current_line]}]: " new_text
                if [ -n "$new_text" ]; then
                    lines[$current_line]="$new_text"
                    modified=true
                fi
                ;;
            j|+)
                # Mover para baixo
                if [ $current_line -lt $((${#lines[@]} - 1)) ]; then
                    current_line=$((current_line + 1))
                fi
                ;;
            k|-)
                # Mover para cima
                if [ $current_line -gt 0 ]; then
                    current_line=$((current_line - 1))
                fi
                ;;
            g)
                # Ir para uma linha específica
                read -p "Ir para linha: " goto_line
                if [[ "$goto_line" =~ ^[0-9]+$ ]]; then
                    goto_line=$((goto_line - 1))  # Ajusta para índice baseado em 0
                    if [ $goto_line -ge 0 ] && [ $goto_line -lt ${#lines[@]} ]; then
                        current_line=$goto_line
                    else
                        echo -e "${RED}Linha fora do intervalo válido (1-${#lines[@]}).${NC}"
                        read -n 1 -p "Pressione qualquer tecla para continuar..."
                    fi
                else
                    echo -e "${RED}Por favor, digite um número válido.${NC}"
                    read -n 1 -p "Pressione qualquer tecla para continuar..."
                fi
                ;;
            h)
                # Mostrar ajuda
                clear
                echo -e "${BLUE}=== Ajuda do ByteEdit ===${NC}"
                echo -e "q       - Sair do editor"
                echo -e "w       - Salvar o arquivo"
                echo -e "n       - Adicionar uma nova linha após a linha atual"
                echo -e "d       - Deletar a linha atual"
                echo -e "e       - Editar a linha atual"
                echo -e "j, +    - Mover para a próxima linha"
                echo -e "k, -    - Mover para a linha anterior"
                echo -e "g       - Ir para uma linha específica"
                echo -e "h       - Mostrar esta ajuda"
                echo ""
                read -n 1 -p "Pressione qualquer tecla para voltar ao editor..."
                ;;
            *)
                echo -e "${RED}Comando desconhecido: $cmd${NC}"
                read -n 1 -p "Pressione qualquer tecla para continuar..."
                ;;
        esac
    done

    clear
    echo -e "${GREEN}Saindo do editor.${NC}"
}

# Executa o editor com o arquivo especificado
byte_edit "$1"