import { defineConfig } from 'vite';
import preact from '@preact/preset-vite';
import WindiCSS from 'vite-plugin-windicss';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    preact(),
    WindiCSS(),
  ],
  server: {
    port: 5173,
    strictPort: true, 
    hmr: {
      clientPort: 5173,
    },
  },
});
