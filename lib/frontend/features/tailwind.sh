#!/bin/bash

setup_tailwind() {
    # Detecta o framework
    local framework=$(detect_framework)
    
    # Cria arquivo de configuração do Tailwind
    cat > tailwind.config.js << EOF
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx,vue,html}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

    # Configuração específica por framework
    case $framework in
        "react"|"next")
            # Atualiza arquivo CSS principal
            cat > src/index.css << EOF
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
            ;;
        "vue")
            # Atualiza arquivo CSS principal
            cat > src/assets/main.css << EOF
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
            ;;
        "angular")
            # Atualiza arquivo CSS principal
            cat > src/styles.scss << EOF
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
            ;;
    esac

    echo -e "${CYBER_GREEN}✔ TailwindCSS configurado com sucesso!${RESET}"
}