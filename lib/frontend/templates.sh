#!/bin/bash

# Template para Redux Slice
generate_redux_slice() {
    local name="$1"
    local dir="src/store/slices"
    
    mkdir -p "$dir"
    
    cat > "$dir/${name}Slice.ts" << EOF
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface ${name}State {
    // Define your state here
}

const initialState: ${name}State = {
    // Initial state
};

export const ${name}Slice = createSlice({
    name: '${name.toLowerCase()}',
    initialState,
    reducers: {
        // Define your reducers here
    },
});

export const { } = ${name}Slice.actions;
export default ${name}Slice.reducer;
EOF

    echo -e "${CYBER_GREEN}✔ Redux Slice para $name gerado com sucesso${RESET}"
}

# Template para Context
generate_context() {
    local name="$1"
    local dir="src/contexts"
    
    mkdir -p "$dir"
    
    cat > "$dir/${name}Context.tsx" << EOF
import React, { createContext, useContext, useState } from 'react';

interface ${name}ContextData {
    // Define your context data here
}

const ${name}Context = createContext<${name}ContextData>({} as ${name}ContextData);

export const ${name}Provider: React.FC = ({ children }) => {
    // Your provider logic here
    
    return (
        <${name}Context.Provider value={{}}>
            {children}
        </${name}Context.Provider>
    );
};

export const use${name} = () => {
    const context = useContext(${name}Context);
    if (!context) {
        throw new Error('use${name} must be used within a ${name}Provider');
    }
    return context;
};
EOF

    echo -e "${CYBER_GREEN}✔ Context para $name gerado com sucesso${RESET}"
}