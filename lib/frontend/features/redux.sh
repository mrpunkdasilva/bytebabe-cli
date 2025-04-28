#!/bin/bash

generate_redux_store() {
    # Cria estrutura de diretórios
    mkdir -p src/store/slices

    # Cria store principal
    cat > src/store/index.ts << EOF
import { configureStore } from '@reduxjs/toolkit';
import counterReducer from './slices/counterSlice';

export const store = configureStore({
  reducer: {
    counter: counterReducer,
    // Adicione outros reducers aqui
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
EOF

    # Cria hooks personalizados
    cat > src/store/hooks.ts << EOF
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import type { RootState, AppDispatch } from './index';

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
EOF

    # Cria slice de exemplo
    cat > src/store/slices/counterSlice.ts << EOF
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CounterState {
  value: number;
}

const initialState: CounterState = {
  value: 0,
};

export const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    incrementByAmount: (state, action: PayloadAction<number>) => {
      state.value += action.payload;
    },
  },
});

export const { increment, decrement, incrementByAmount } = counterSlice.actions;
export default counterSlice.reducer;
EOF

    # Atualiza o arquivo principal para incluir o Provider
    if [ -f "src/main.tsx" ]; then
        cat > src/main.tsx << EOF
import React from 'react';
import ReactDOM from 'react-dom/client';
import { Provider } from 'react-redux';
import { store } from './store';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </React.StrictMode>
);
EOF
    fi

    echo -e "${CYBER_GREEN}✔ Redux Toolkit configurado com sucesso!${RESET}"
    echo -e "${CYBER_BLUE}Exemplo de uso:${RESET}"
    echo -e "import { useAppDispatch, useAppSelector } from './store/hooks';"
    echo -e "const count = useAppSelector((state) => state.counter.value);"
    echo -e "const dispatch = useAppDispatch();"
}