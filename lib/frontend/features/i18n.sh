#!/bin/bash

generate_i18n_setup() {
    # Cria estrutura de diretórios
    mkdir -p src/i18n/locales

    # Cria arquivos de tradução
    cat > src/i18n/locales/en.json << EOF
{
  "common": {
    "welcome": "Welcome",
    "about": "About",
    "home": "Home"
  },
  "home": {
    "title": "Welcome to our app",
    "description": "This is a sample application"
  },
  "about": {
    "title": "About Us",
    "description": "Learn more about our team"
  }
}
EOF

    cat > src/i18n/locales/pt.json << EOF
{
  "common": {
    "welcome": "Bem-vindo",
    "about": "Sobre",
    "home": "Início"
  },
  "home": {
    "title": "Bem-vindo ao nosso app",
    "description": "Este é um aplicativo de exemplo"
  },
  "about": {
    "title": "Sobre Nós",
    "description": "Saiba mais sobre nossa equipe"
  }
}
EOF

    # Cria configuração do i18n
    cat > src/i18n/index.ts << EOF
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import enTranslations from './locales/en.json';
import ptTranslations from './locales/pt.json';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: {
        translation: enTranslations
      },
      pt: {
        translation: ptTranslations
      }
    },
    lng: 'en',
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false
    }
  });

export default i18n;
EOF

    # Atualiza o arquivo principal
    cat > src/main.tsx << EOF
import React from 'react';
import ReactDOM from 'react-dom/client';
import './i18n';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

    # Cria componente de exemplo com i18n
    cat > src/components/LanguageSwitcher.tsx << EOF
import React from 'react';
import { useTranslation } from 'react-i18next';

export const LanguageSwitcher = () => {
  const { i18n } = useTranslation();

  const changeLanguage = (lng: string) => {
    i18n.changeLanguage(lng);
  };

  return (
    <div className="flex space-x-2">
      <button onClick={() => changeLanguage('en')}>EN</button>
      <button onClick={() => changeLanguage('pt')}>PT</button>
    </div>
  );
};
EOF

    echo -e "${CYBER_GREEN}✔ i18n configurado com sucesso!${RESET}"
    echo -e "${CYBER_BLUE}Exemplo de uso:${RESET}"
    echo -e "import { useTranslation } from 'react-i18next';"
    echo -e "const { t } = useTranslation();"
    echo -e "t('common.welcome')"
}

generate_vue_i18n() {
    # Cria estrutura de diretórios
    mkdir -p src/i18n/locales

    # Cria arquivos de tradução
    cat > src/i18n/locales/en.json << EOF
{
  "common": {
    "welcome": "Welcome",
    "about": "About",
    "home": "Home"
  },
  "home": {
    "title": "Welcome to our app",
    "description": "This is a sample application"
  },
  "about": {
    "title": "About Us",
    "description": "Learn more about our team"
  }
}
EOF

    cat > src/i18n/locales/pt.json << EOF
{
  "common": {
    "welcome": "Bem-vindo",
    "about": "Sobre",
    "home": "Início"
  },
  "home": {
    "title": "Bem-vindo ao nosso app",
    "description": "Este é um aplicativo de exemplo"
  },
  "about": {
    "title": "Sobre Nós",
    "description": "Saiba mais sobre nossa equipe"
  }
}
EOF

    # Cria configuração do i18n
    cat > src/i18n/index.ts << EOF
import { createI18n } from 'vue-i18n';
import en from './locales/en.json';
import pt from './locales/pt.json';

export default createI18n({
  legacy: false,
  locale: 'en',
  fallbackLocale: 'en',
  messages: {
    en,
    pt
  }
});
EOF

    # Atualiza o arquivo principal
    cat > src/main.ts << EOF
import { createApp } from 'vue';
import App from './App.vue';
import i18n from './i18n';
import './assets/main.css';

const app = createApp(App);
app.use(i18n);
app.mount('#app');
EOF

    echo -e "${CYBER_GREEN}✔ Vue i18n configurado com sucesso!${RESET}"
}