#!/bin/bash

# Dialog para gerenciamento de banco de dados
show_database_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Database Management ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 8 \
                       "1" "🔌 Connections" \
                       "2" "📋 Table Browser" \
                       "3" "📝 Query Editor" \
                       "4" "📊 Data Viewer" \
                       "5" "📤 Export Tools" \
                       "6" "📥 Import Tools" \
                       "7" "🔄 Backup/Restore" \
                       "8" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) show_connections_menu ;;
            2) show_table_browser ;;
            3) show_query_editor ;;
            4) show_data_viewer ;;
            5) show_export_menu ;;
            6) show_import_menu ;;
            7) show_backup_menu ;;
            8) break ;;
            *) break ;;
        esac
    done
}

# Dialog para gerenciamento de conexões
show_connections_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Database Connections ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 6 \
                       "1" "📋 List Connections" \
                       "2" "➕ New Connection" \
                       "3" "✏️  Edit Connection" \
                       "4" "🔍 Test Connection" \
                       "5" "🗑️  Remove Connection" \
                       "6" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) list_connections_dialog ;;
            2) new_connection_dialog ;;
            3) edit_connection_dialog ;;
            4) test_connection_dialog ;;
            5) remove_connection_dialog ;;
            6) break ;;
            *) break ;;
        esac
    done
}

# Dialog para criar nova conexão
new_connection_dialog() {
    local name
    local type
    local host
    local port
    local database
    local user
    local password
    
    # Nome da conexão
    name=$(dialog --clear \
                 --backtitle "$DIALOG_BACKTITLE" \
                 --title "[ New Connection ]" \
                 --inputbox "Connection name:" \
                 10 50 \
                 2>&1 >/dev/tty)
    
    # Tipo de banco
    type=$(dialog --clear \
                 --backtitle "$DIALOG_BACKTITLE" \
                 --title "[ Database Type ]" \
                 --menu "Select database type:" \
                 $DIALOG_HEIGHT $DIALOG_WIDTH 4 \
                 "1" "PostgreSQL" \
                 "2" "MySQL" \
                 "3" "MongoDB" \
                 "4" "SQLite" \
                 2>&1 >/dev/tty)
    
    # Host
    host=$(dialog --clear \
                 --backtitle "$DIALOG_BACKTITLE" \
                 --title "[ Host ]" \
                 --inputbox "Database host:" \
                 10 50 "localhost" \
                 2>&1 >/dev/tty)
    
    # Port
    port=$(dialog --clear \
                 --backtitle "$DIALOG_BACKTITLE" \
                 --title "[ Port ]" \
                 --inputbox "Database port:" \
                 10 50 "5432" \
                 2>&1 >/dev/tty)
    
    # Database name
    database=$(dialog --clear \
                     --backtitle "$DIALOG_BACKTITLE" \
                     --title "[ Database ]" \
                     --inputbox "Database name:" \
                     10 50 \
                     2>&1 >/dev/tty)
    
    # Username
    user=$(dialog --clear \
                 --backtitle "$DIALOG_BACKTITLE" \
                 --title "[ Username ]" \
                 --inputbox "Database user:" \
                 10 50 \
                 2>&1 >/dev/tty)
    
    # Password
    password=$(dialog --clear \
                     --backtitle "$DIALOG_BACKTITLE" \
                     --title "[ Password ]" \
                     --passwordbox "Database password:" \
                     10 50 \
                     2>&1 >/dev/tty)
    
    # Salva a conexão
    save_connection "$name" "$type" "$host" "$port" "$database" "$user" "$password"
}

# Dialog para navegador de tabelas
show_table_browser() {
    local conn=$(select_connection_dialog)
    [ -z "$conn" ] && return
    
    while true; do
        local tables=$(list_tables "$conn")
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Table Browser - $conn ]" \
                       --menu "Select table:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
                       $(echo "$tables" | awk '{print NR " " $0}') \
                       2>&1 >/dev/tty)
        
        [ -z "$choice" ] && break
        
        local selected_table=$(echo "$tables" | sed -n "${choice}p")
        show_table_operations_menu "$conn" "$selected_table"
    done
}

# Dialog para operações em tabela
show_table_operations_menu() {
    local conn="$1"
    local table="$2"
    
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Table: $table ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 7 \
                       "1" "👀 View Data" \
                       "2" "📊 Show Structure" \
                       "3" "📝 Edit Data" \
                       "4" "📤 Export Table" \
                       "5" "🗑️  Truncate Table" \
                       "6" "📈 Table Stats" \
                       "7" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) view_table_data_dialog "$conn" "$table" ;;
            2) show_table_structure_dialog "$conn" "$table" ;;
            3) edit_table_data_dialog "$conn" "$table" ;;
            4) export_table_dialog "$conn" "$table" ;;
            5) truncate_table_dialog "$conn" "$table" ;;
            6) show_table_stats_dialog "$conn" "$table" ;;
            7) break ;;
            *) break ;;
        esac
    done
}

# Dialog para editor de queries
show_query_editor() {
    local conn=$(select_connection_dialog)
    [ -z "$conn" ] && return
    
    local query=$(dialog --clear \
                        --backtitle "$DIALOG_BACKTITLE" \
                        --title "[ Query Editor ]" \
                        --editbox /tmp/query.sql \
                        20 70 \
                        2>&1 >/dev/tty)
    
    if [ $? -eq 0 ]; then
        execute_query "$conn" "$query" | \
        dialog --clear \
               --backtitle "$DIALOG_BACKTITLE" \
               --title "[ Query Results ]" \
               --textbox - \
               20 70
    fi
}

# Dialog para visualizador de dados
show_data_viewer() {
    local conn=$(select_connection_dialog)
    [ -z "$conn" ] && return
    
    local table=$(select_table_dialog "$conn")
    [ -z "$table" ] && return
    
    view_table_data "$conn" "$table" | \
    dialog --clear \
           --backtitle "$DIALOG_BACKTITLE" \
           --title "[ Data Viewer: $table ]" \
           --textbox - \
           20 70
}

# Dialog para exportação
show_export_menu() {
    local conn=$(select_connection_dialog)
    [ -z "$conn" ] && return
    
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Export Tools ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 5 \
                       "1" "📋 Export Table" \
                       "2" "📊 Export Query Result" \
                       "3" "📦 Export Database" \
                       "4" "📑 Export Schema" \
                       "5" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) export_table_dialog "$conn" ;;
            2) export_query_dialog "$conn" ;;
            3) export_database_dialog "$conn" ;;
            4) export_schema_dialog "$conn" ;;
            5) break ;;
            *) break ;;
        esac
    done
}

# Dialog para importação
show_import_menu() {
    local conn=$(select_connection_dialog)
    [ -z "$conn" ] && return
    
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Import Tools ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 5 \
                       "1" "📥 Import CSV" \
                       "2" "📥 Import SQL" \
                       "3" "📥 Import JSON" \
                       "4" "📥 Import Excel" \
                       "5" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) import_csv_dialog "$conn" ;;
            2) import_sql_dialog "$conn" ;;
            3) import_json_dialog "$conn" ;;
            4) import_excel_dialog "$conn" ;;
            5) break ;;
            *) break ;;
        esac
    done
}

# Dialog para backup/restore
show_backup_menu() {
    local conn=$(select_connection_dialog)
    [ -z "$conn" ] && return
    
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Backup/Restore ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 4 \
                       "1" "💾 Create Backup" \
                       "2" "📥 Restore Backup" \
                       "3" "📋 List Backups" \
                       "4" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) create_backup_dialog "$conn" ;;
            2) restore_backup_dialog "$conn" ;;
            3) list_backups_dialog "$conn" ;;
            4) break ;;
            *) break ;;
        esac
    done
}