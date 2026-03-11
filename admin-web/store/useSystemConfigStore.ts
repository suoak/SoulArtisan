import { create } from 'zustand';
import { SystemConfig } from '../types';
import { getPublicSystemConfig } from '../api/system';

// 从环境变量获取项目配置
const APP_TITLE = import.meta.env.VITE_APP_TITLE;
const APP_COPYRIGHT = import.meta.env.VITE_APP_COPYRIGHT;

// 环境变量强制覆盖的字段（.env 优先于数据库配置）
const ENV_OVERRIDES = {
  systemTitle: APP_TITLE,
  copyright: APP_COPYRIGHT,
  loginTitle: APP_TITLE,
};

// 默认配置
const DEFAULT_CONFIG: SystemConfig = {
  systemTitle: APP_TITLE,
  systemLogo: '',
  systemFavicon: '',
  copyright: APP_COPYRIGHT,
  footerText: '',
  icpBeian: '',
  loginBgImage: '',
  loginTitle: APP_TITLE,
  loginSubtitle: '登录以继续使用系统',
  primaryColor: '#6366f1',
};

interface SystemConfigState {
  config: SystemConfig;
  isLoading: boolean;
  isLoaded: boolean;
  setConfig: (config: SystemConfig) => void;
  loadConfig: () => Promise<void>;
  updateFavicon: (faviconUrl: string) => void;
  updateTitle: (title: string) => void;
}

export const useSystemConfigStore = create<SystemConfigState>((set, get) => ({
  config: DEFAULT_CONFIG,
  isLoading: false,
  isLoaded: false,

  setConfig: (config) => {
    // 合并配置：默认值 -> API值 -> 环境变量强制覆盖
    set({ config: { ...DEFAULT_CONFIG, ...config, ...ENV_OVERRIDES } });
    // 更新页面 favicon 和 title
    get().updateFavicon(config.systemFavicon || '');
    get().updateTitle(ENV_OVERRIDES.systemTitle);
  },

  loadConfig: async () => {
    const { isLoaded, isLoading } = get();
    if (isLoaded || isLoading) return;

    set({ isLoading: true });
    try {
      const config = await getPublicSystemConfig();
      // 合并配置：默认值 -> API值 -> 环境变量强制覆盖
      set({
        config: { ...DEFAULT_CONFIG, ...config, ...ENV_OVERRIDES },
        isLoading: false,
        isLoaded: true,
      });
      // 更新页面 favicon 和 title
      get().updateFavicon(config.systemFavicon || '');
      get().updateTitle(ENV_OVERRIDES.systemTitle);
    } catch (error) {
      // 加载失败使用默认配置
      set({
        config: DEFAULT_CONFIG,
        isLoading: false,
        isLoaded: true,
      });
      console.error('加载系统配置失败:', error);
    }
  },

  updateFavicon: (faviconUrl: string) => {
    if (!faviconUrl) return;

    // 更新或创建 favicon link 标签
    let link = document.querySelector("link[rel~='icon']") as HTMLLinkElement;
    if (!link) {
      link = document.createElement('link');
      link.rel = 'icon';
      document.head.appendChild(link);
    }
    link.href = faviconUrl;
  },

  updateTitle: (title: string) => {
    document.title = title;
  },
}));
