#!/bin/bash

# Gera componente React
generate_react_component() {
    local name="$1"
    local dir="src/components/$name"
    
    mkdir -p "$dir"
    
    # Componente
    cat > "$dir/$name.tsx" << EOF
import React from 'react';
import './$name.scss';

interface ${name}Props {
    // Define your props here
}

export const $name: React.FC<${name}Props> = (props) => {
    return (
        <div className="${name}">
            {/* Your component content */}
        </div>
    );
};
EOF

    # Estilos
    cat > "$dir/$name.scss" << EOF
.${name} {
    // Your styles here
}
EOF

    # Testes
    cat > "$dir/$name.test.tsx" << EOF
import { render } from '@testing-library/react';
import { $name } from './$name';

describe('$name', () => {
    it('should render successfully', () => {
        const { baseElement } = render(<$name />);
        expect(baseElement).toBeTruthy();
    });
});
EOF
}

# Gera hook personalizado React
generate_react_hook() {
    local name="$1"
    local dir="src/hooks"
    
    mkdir -p "$dir"
    
    cat > "$dir/use$name.ts" << EOF
import { useState, useEffect } from 'react';

export const use$name = () => {
    // Your hook logic here
    
    return {
        // Return values here
    };
};
EOF
}

# Gera Context React
generate_react_context() {
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
}
# Gera página React
generate_react_page() {
    local name="$1"
    local dir="src/pages/$name"

    mkdir -p "$dir"

    cat > "$dir/index.tsx" << TEMPLATE
import React from 'react';
import './styles.scss';

export const ${name}Page: React.FC = () => {
    return (
        <div className="${name}Page">
            <h1>${name}</h1>
        </div>
    );
};

export default ${name}Page;
TEMPLATE

    cat > "$dir/styles.scss" << TEMPLATE
.${name}Page {
    // Your styles here
}
TEMPLATE
}

# Gera serviço de API React
generate_api_service() {
    local name="$1"
    local dir="src/services"

    mkdir -p "$dir"

    cat > "$dir/${name}Service.ts" << TEMPLATE
import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL;

export class ${name}Service {
    static async getAll() {
        return axios.get(\`\${API_URL}/${name.toLowerCase()}\`);
    }

    static async getById(id: string) {
        return axios.get(\`\${API_URL}/${name.toLowerCase()}/\${id}\`);
    }

    static async create(data: any) {
        return axios.post(\`\${API_URL}/${name.toLowerCase()}\`, data);
    }

    static async update(id: string, data: any) {
        return axios.put(\`\${API_URL}/${name.toLowerCase()}/\${id}\`, data);
    }

    static async delete(id: string) {
        return axios.delete(\`\${API_URL}/${name.toLowerCase()}/\${id}\`);
    }
}
TEMPLATE
}
