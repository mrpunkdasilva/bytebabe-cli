#!/bin/bash

generate_react_router() {
    # Cria estrutura de diretórios
    mkdir -p src/routes src/pages

    # Cria páginas de exemplo
    cat > src/pages/Home.tsx << EOF
import React from 'react';

export const Home = () => {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold">Home Page</h1>
    </div>
  );
};
EOF

    cat > src/pages/About.tsx << EOF
import React from 'react';

export const About = () => {
  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold">About Page</h1>
    </div>
  );
};
EOF

    # Cria componente de layout
    cat > src/components/Layout.tsx << EOF
import React from 'react';
import { Link, Outlet } from 'react-router-dom';

export const Layout = () => {
  return (
    <div>
      <nav className="bg-gray-800 text-white p-4">
        <ul className="flex space-x-4">
          <li><Link to="/">Home</Link></li>
          <li><Link to="/about">About</Link></li>
        </ul>
      </nav>
      <main>
        <Outlet />
      </main>
    </div>
  );
};
EOF

    # Cria arquivo de rotas
    cat > src/routes/index.tsx << EOF
import { createBrowserRouter } from 'react-router-dom';
import { Layout } from '../components/Layout';
import { Home } from '../pages/Home';
import { About } from '../pages/About';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        index: true,
        element: <Home />,
      },
      {
        path: 'about',
        element: <About />,
      },
    ],
  },
]);
EOF

    # Atualiza o arquivo principal
    cat > src/main.tsx << EOF
import React from 'react';
import ReactDOM from 'react-dom/client';
import { RouterProvider } from 'react-router-dom';
import { router } from './routes';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
);
EOF

    echo -e "${CYBER_GREEN}✔ React Router configurado com sucesso!${RESET}"
}

generate_vue_router() {
    # Cria estrutura de diretórios
    mkdir -p src/router src/views

    # Cria views de exemplo
    cat > src/views/HomeView.vue << EOF
<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold">Home Page</h1>
  </div>
</template>
EOF

    cat > src/views/AboutView.vue << EOF
<template>
  <div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold">About Page</h1>
  </div>
</template>
EOF

    # Cria arquivo de rotas
    cat > src/router/index.ts << EOF
import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import AboutView from '../views/AboutView.vue';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/about',
      name: 'about',
      component: AboutView
    }
  ]
});

export default router;
EOF

    # Atualiza o arquivo principal
    cat > src/App.vue << EOF
<template>
  <header>
    <nav class="bg-gray-800 text-white p-4">
      <RouterLink to="/">Home</RouterLink> |
      <RouterLink to="/about">About</RouterLink>
    </nav>
  </header>

  <RouterView />
</template>

<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
</script>
EOF

    echo -e "${CYBER_GREEN}✔ Vue Router configurado com sucesso!${RESET}"
}