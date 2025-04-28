#!/bin/bash

# Gera componente Vue
generate_vue_component() {
    local name="$1"
    local dir="src/components/$name"
    
    mkdir -p "$dir"
    
    # Componente
    cat > "$dir/$name.vue" << EOF
<template>
  <div class="${name}">
    <!-- Your template here -->
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
  name: '$name',
  props: {
    // Define your props here
  },
  setup(props) {
    // Component logic here
    return {
      // Return reactive data
    }
  }
})
</script>

<style lang="scss" scoped>
.${name} {
  // Your styles here
}
</style>
EOF

    # Testes
    cat > "$dir/$name.spec.ts" << EOF
import { mount } from '@vue/test-utils'
import $name from './$name.vue'

describe('$name', () => {
  it('renders properly', () => {
    const wrapper = mount($name)
    expect(wrapper.exists()).toBe(true)
  })
})
EOF
}

# Gera composable Vue
generate_vue_composable() {
    local name="$1"
    local dir="src/composables"
    
    mkdir -p "$dir"
    
    cat > "$dir/use$name.ts" << EOF
import { ref, computed } from 'vue'

export function use$name() {
    // Your composable logic here
    
    return {
        // Return reactive data and methods
    }
}
EOF
}

# Gera store Vue (Pinia)
generate_vue_store() {
    local name="$1"
    local dir="src/stores"
    
    mkdir -p "$dir"
    
    cat > "$dir/${name}Store.ts" << EOF
import { defineStore } from 'pinia'

export const use${name}Store = defineStore('${name}', {
    state: () => ({
        // Define your state here
    }),
    
    getters: {
        // Define your getters here
    },
    
    actions: {
        // Define your actions here
    }
})
EOF
}