import React, { useState, useContext, useRef } from 'react';
import { Sparkles, Plus, ArrowUp, Hammer, Bot, Image as ImageIcon, FolderPlus, User, LogOut, ChevronDown, X, Loader2 } from 'lucide-react';
import AuthContext from '@/contexts/AuthContext';
import { upload, showError, showSuccess } from '@/utils/request';

interface UploadedFile {
  id: number;
  url: string;
  fileName: string;
  fileType: string;
  fileSize: number;
}

interface HomePageProps {
  onStart: (prompt: string, uploadedFile?: UploadedFile) => void;
  onEnterCanvas: () => void;
  onGoLogin: () => void;
  onGoRegister: () => void;
}

type CreationMode = 'chat' | 'image';

const HomePage: React.FC<HomePageProps> = ({ onStart, onEnterCanvas, onGoLogin, onGoRegister }) => {
  const auth = useContext(AuthContext);
  const [input, setInput] = useState('');
  const [activeMode, setActiveMode] = useState<CreationMode>('image');
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [uploadedFile, setUploadedFile] = useState<UploadedFile | null>(null);
  const [uploading, setUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (input.trim()) {
      onStart(input, uploadedFile || undefined);
    }
  };

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // 验证文件类型
    if (!file.type.startsWith('image/')) {
      showError('请选择图片文件');
      return;
    }

    // 验证文件大小 (10MB)
    if (file.size > 10 * 1024 * 1024) {
      showError('图片大小不能超过10MB');
      return;
    }

    setUploading(true);
    try {
      const response = await upload<{ code: number; data: UploadedFile }>('/api/file/upload', file);
      if (response.data.code === 200) {
        setUploadedFile(response.data.data);
        showSuccess('图片上传成功');
      }
    } catch {
      showError('图片上传失败');
    } finally {
      setUploading(false);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    }
  };

  const handleRemoveFile = () => {
    setUploadedFile(null);
  };

  const handleLogout = () => {
    auth?.logout();
    setShowUserMenu(false);
  };

  return (
    <div className="min-h-screen flex flex-col items-center relative overflow-hidden">
      {/* 顶部 Logo 区域 */}
      <header className="w-full p-8 flex items-center justify-between z-10">
        <div className="flex items-center gap-4">
          <div className="w-11 h-11 bg-black rounded-xl flex items-center justify-center shadow-lg hover:scale-105 transition-transform cursor-pointer">
            <Hammer className="text-white" size={20} />
          </div>
          <div className="flex flex-col -gap-1">
            <h1 className="text-2xl font-black tracking-tighter text-gray-900 leading-none">灵匠</h1>
            <span className="text-[9px] font-black uppercase tracking-[0.2em] text-gray-400">Artisan AI Lab</span>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <button
            onClick={onEnterCanvas}
            className="flex items-center gap-2 px-5 py-2.5 bg-white border border-gray-100 text-gray-900 rounded-xl font-bold text-sm hover:bg-gray-50 active:scale-95 transition-all shadow-sm relative z-50"
          >
            <FolderPlus size={18} />
            进入画布
          </button>

          {auth?.isAuthenticated && auth?.userInfo ? (
            <div className="relative">
              <button
                onClick={() => setShowUserMenu(!showUserMenu)}
                className="flex items-center gap-2 px-4 py-2.5 bg-white border border-gray-100 text-gray-900 rounded-xl font-medium text-sm hover:bg-gray-50 transition-all shadow-sm"
              >
                <div className="w-7 h-7 bg-indigo-100 rounded-lg flex items-center justify-center">
                  <User size={16} className="text-indigo-600" />
                </div>
                <span className="max-w-[100px] truncate">{auth.userInfo.nickname || auth.userInfo.username}</span>
                <ChevronDown size={16} className={`text-gray-400 transition-transform ${showUserMenu ? 'rotate-180' : ''}`} />
              </button>

              {showUserMenu && (
                <>
                  <div className="fixed inset-0 z-40" onClick={() => setShowUserMenu(false)} />
                  <div className="absolute right-0 top-full mt-2 w-48 bg-white rounded-xl shadow-xl border border-gray-100 py-2 z-50">
                    <div className="px-4 py-2 border-b border-gray-100">
                      <p className="text-sm font-bold text-gray-900 truncate">{auth.userInfo.nickname || auth.userInfo.username}</p>
                      <p className="text-xs text-gray-400 truncate">{auth.userInfo.email || `积分: ${auth.userInfo.points}`}</p>
                    </div>
                    <button
                      onClick={handleLogout}
                      className="w-full px-4 py-2.5 text-left text-sm text-red-500 hover:bg-red-50 flex items-center gap-2 transition-colors"
                    >
                      <LogOut size={16} />
                      退出登录
                    </button>
                  </div>
                </>
              )}
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <button
                onClick={onGoLogin}
                className="px-5 py-2.5 bg-white border border-gray-100 text-gray-900 rounded-xl font-bold text-sm hover:bg-gray-50 active:scale-95 transition-all shadow-sm"
              >
                登录
              </button>
              <button
                onClick={onGoRegister}
                className="px-5 py-2.5 bg-black text-white rounded-xl font-bold text-sm hover:opacity-90 active:scale-95 transition-all shadow-lg"
              >
                注册
              </button>
            </div>
          )}
        </div>
      </header>

      {/* 主体内容 */}
      <main className="flex-1 flex flex-col items-center justify-center -mt-32 px-6 w-full max-w-4xl z-10">
        <div className="text-center mb-12 space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 bg-white/80 border border-gray-100 rounded-full shadow-sm">
            <Sparkles className="text-indigo-500" size={14} />
            <span className="text-[10px] font-black uppercase tracking-widest text-gray-500">AI 时代的创意重塑</span>
          </div>
          <h2 className="text-6xl font-black text-gray-900 tracking-tight">
            {auth?.isAuthenticated && auth?.userInfo ? (
              <>欢迎回来，<span className="text-indigo-600">{auth.userInfo.nickname || auth.userInfo.username}</span></>
            ) : (
              <>你好，<span className="text-indigo-600">灵匠</span></>
            )}
          </h2>
          <p className="text-lg text-gray-400 font-medium max-w-lg mx-auto leading-relaxed">
            在一个无限的创意空间中，捕捉灵感并将其转化为现实。
          </p>
        </div>

        {/* 核心输入框 */}
        <div className="w-full relative">
          <form
            onSubmit={handleSubmit}
            className="w-full bg-white/90 backdrop-blur-xl border border-gray-100 shadow-[0_32px_80px_-16px_rgba(0,0,0,0.08)] rounded-[32px] p-4 flex flex-col gap-4 focus-within:ring-4 focus-within:ring-indigo-500/5 transition-all"
          >
            <div className="px-4 pt-2">
              <textarea
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder={
                  activeMode === 'chat' ? "与灵匠对话，探索创意边界..." :
                  "描述您想要创造的画面..."
                }
                className="w-full text-xl font-medium text-gray-800 placeholder:text-gray-300 outline-none resize-none h-24 py-2 bg-transparent"
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    handleSubmit(e);
                  }
                }}
              />
            </div>

            {/* 已上传图片预览 */}
            {uploadedFile && (
              <div className="px-4">
                <div className="relative inline-block">
                  <img
                    src={uploadedFile.url}
                    alt={uploadedFile.fileName}
                    className="h-20 w-20 object-cover rounded-xl border border-gray-200"
                  />
                  <button
                    type="button"
                    onClick={handleRemoveFile}
                    className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center hover:bg-red-600 transition-colors"
                  >
                    <X size={14} />
                  </button>
                </div>
              </div>
            )}

            <div className="flex items-center justify-between px-2 pb-2">
              <div className="flex items-center gap-2.5">
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleFileSelect}
                  className="hidden"
                />
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  disabled={uploading}
                  className="group w-10 h-10 border border-gray-100 rounded-xl flex items-center justify-center text-gray-400 hover:bg-gray-50 transition-all disabled:opacity-50"
                >
                  {uploading ? (
                    <Loader2 size={20} className="animate-spin" />
                  ) : (
                    <Plus size={20} className="group-hover:rotate-90 transition-transform" />
                  )}
                </button>

                {/* 模式切换器 */}
                <div className="flex items-center bg-[#4a4a4a] p-1 rounded-2xl gap-0.5">
                  <button
                    type="button"
                    onClick={() => setActiveMode('chat')}
                    className={`w-9 h-9 flex items-center justify-center rounded-xl transition-all ${
                      activeMode === 'chat' ? 'bg-[#f3f4f6] text-gray-800 shadow-sm' : 'text-gray-400 hover:text-white'
                    }`}
                  >
                    <Bot size={18} />
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveMode('image')}
                    className={`w-9 h-9 flex items-center justify-center rounded-xl transition-all ${
                      activeMode === 'image' ? 'bg-[#f3f4f6] text-gray-800 shadow-sm' : 'text-gray-400 hover:text-white'
                    }`}
                  >
                    <ImageIcon size={18} />
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={!input.trim()}
                className={`flex items-center gap-2 px-8 h-12 rounded-2xl font-black text-xs uppercase tracking-widest transition-all
                  ${input.trim() ? 'bg-black text-white hover:scale-105 active:scale-95 shadow-xl shadow-black/10' : 'bg-gray-100 text-gray-300 cursor-not-allowed'}`}
              >
                唤醒灵感
                <ArrowUp size={18} strokeWidth={3} />
              </button>
            </div>
          </form>

          {/* 快捷推荐 */}
          <div className="flex justify-center gap-2 mt-8">
            {['极简美学', '未来实验室', '中式山水', '机械之心'].map(tag => (
              <button
                key={tag}
                onClick={() => setInput(tag)}
                className="px-4 py-1.5 bg-white border border-gray-100 rounded-full text-[11px] font-bold text-gray-400 hover:text-indigo-500 hover:border-indigo-100 transition-all"
              >
                #{tag}
              </button>
            ))}
          </div>
        </div>
      </main>

      {/* 底部版权/信息 */}
      <footer className="w-full p-8 text-center text-[10px] font-black uppercase tracking-[0.3em] text-gray-300 z-10">
        © 2025 LING JIANG LAB · CRAFTED WITH AI
      </footer>
    </div>
  );
};

export default HomePage;
