import path from 'path';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, '.', '');
    return {
    server: {
        host: '0.0.0.0', // 允许外部访问
        port: 3000,
        strictPort: true, // 如果端口被占用则报错
        cors: true, // 启用 CORS
        allowedHosts: ['www.matuto.com', 'localhost', '127.0.0.1'], // 允许的主机名
        proxy: {
            '/api': {
                target: 'http://localhost:30520',
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/api/, '/api')
            }
        }
    },
      plugins: [react()],
      define: {
        'process.env.API_KEY': JSON.stringify(env.GEMINI_API_KEY),
        'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY)
      },
        base: '/', // 使用绝对路径，确保 SPA 路由刷新时资源路径正确
        resolve: {
            alias: {
                '@': path.resolve(__dirname, './src'),
            },
        },
    };
});
