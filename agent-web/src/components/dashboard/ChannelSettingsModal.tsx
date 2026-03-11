import React, { useState, useEffect } from 'react';
import { useWorkflowStore } from './hooks/useWorkflowStore';
import { getCapabilities, getChatModelList, type CapabilityInfo, type ChannelInfo, type ChatModelInfo } from '@/api/capability';
import './ChannelSettingsModal.css';

interface ChannelSettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
}

// 选中的渠道信息
interface SelectedChannel {
  channel: string | null;
  model: string | null;
}

const ChannelSettingsModal: React.FC<ChannelSettingsModalProps> = ({ isOpen, onClose }) => {
  const { channelSettings, setChannelSettings } = useWorkflowStore();

  const [capabilities, setCapabilities] = useState<CapabilityInfo[]>([]);
  const [chatModels, setChatModels] = useState<ChatModelInfo[]>([]);
  const [loading, setLoading] = useState(false);

  // 图片渠道选择
  const [imageSelection, setImageSelection] = useState<SelectedChannel>({
    channel: channelSettings.imageChannel,
    model: channelSettings.imageModel,
  });

  // 视频渠道选择
  const [videoSelection, setVideoSelection] = useState<SelectedChannel>({
    channel: channelSettings.videoChannel,
    model: channelSettings.videoModel,
  });

  // 对话模型选择
  const [chatModelSelection, setChatModelSelection] = useState<string | null>(channelSettings.chatModel);

  // 加载能力列表和对话模型
  useEffect(() => {
    if (isOpen) {
      loadCapabilities();
      loadChatModels();
      // 同步当前设置
      setImageSelection({
        channel: channelSettings.imageChannel,
        model: channelSettings.imageModel,
      });
      setVideoSelection({
        channel: channelSettings.videoChannel,
        model: channelSettings.videoModel,
      });
      setChatModelSelection(channelSettings.chatModel);
    }
  }, [isOpen, channelSettings]);

  const loadCapabilities = async () => {
    setLoading(true);
    try {
      const response = await getCapabilities();
      if (response.code === 200 && response.data) {
        setCapabilities(response.data);
        // 如果当前没有选中渠道，自动选择第一个
        autoSelectFirst(response.data);
      }
    } catch (error) {
      console.error('加载能力列表失败:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadChatModels = async () => {
    try {
      const response = await getChatModelList();
      if (response.code === 200 && response.data) {
        setChatModels(response.data);
        // 如果当前没有选中模型，自动选择第一个
        if (!channelSettings.chatModel && response.data.length > 0) {
          setChatModelSelection(response.data[0].id);
        }
      }
    } catch (error) {
      console.error('加载对话模型列表失败:', error);
    }
  };

  // 自动选择第一个渠道
  const autoSelectFirst = (caps: CapabilityInfo[]) => {
    const imageCaps = caps.filter(c => c.type === 'image');
    const videoCaps = caps.filter(c => c.type === 'video');

    // 图片：如果当前没有选中，选第一个
    if (!channelSettings.imageChannel && imageCaps.length > 0 && imageCaps[0].channels.length > 0) {
      const firstChannel = imageCaps[0].channels[0];
      setImageSelection({ channel: firstChannel.channel_type, model: imageCaps[0].code });
    }

    // 视频：如果当前没有选中，选第一个
    if (!channelSettings.videoChannel && videoCaps.length > 0 && videoCaps[0].channels.length > 0) {
      const firstChannel = videoCaps[0].channels[0];
      setVideoSelection({ channel: firstChannel.channel_type, model: videoCaps[0].code });
    }
  };

  // 分离图片和视频能力
  const imageCapabilities = capabilities.filter(c => c.type === 'image');
  const videoCapabilities = capabilities.filter(c => c.type === 'video');

  // 选择图片渠道
  const handleImageChannelSelect = (capCode: string, channel: ChannelInfo) => {
    setImageSelection({
      channel: channel.channel_type,
      model: capCode,
    });
  };

  // 选择视频渠道
  const handleVideoChannelSelect = (capCode: string, channel: ChannelInfo) => {
    setVideoSelection({
      channel: channel.channel_type,
      model: capCode,
    });
  };

  // 保存设置
  const handleSave = () => {
    setChannelSettings({
      imageChannel: imageSelection.channel,
      imageModel: imageSelection.model,
      videoChannel: videoSelection.channel,
      videoModel: videoSelection.model,
      chatModel: chatModelSelection,
    });
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="channel-modal-overlay" onClick={onClose}>
      <div className="channel-modal" onClick={e => e.stopPropagation()}>
        <div className="channel-modal-header">
          <h2>渠道设置</h2>
          <button className="channel-modal-close" onClick={onClose}>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M18 6L6 18M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="channel-modal-body">
          {loading ? (
            <div className="channel-loading">
              <div className="channel-loading-spinner" />
              <span>加载中...</span>
            </div>
          ) : (
            <>
              {/* 对话模型设置 */}
              <div className="channel-section">
                <h3 className="channel-section-title">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="channel-section-icon">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                  </svg>
                  对话模型
                </h3>
                <div className="channel-list">
                  {chatModels.length > 0 ? (
                    <div className="channel-capability-group">
                      {chatModels.map(model => (
                        <label key={model.id} className="channel-item">
                          <input
                            type="radio"
                            name="chatModel"
                            value={model.id}
                            checked={chatModelSelection === model.id}
                            onChange={() => setChatModelSelection(model.id)}
                          />
                          <span className="channel-radio" />
                          <div className="channel-info">
                            <span className="channel-name">{model.id}</span>
                            <span className="channel-desc">提供商: {model.owned_by}</span>
                          </div>
                        </label>
                      ))}
                    </div>
                  ) : (
                    <div className="channel-empty">暂无可用的对话模型</div>
                  )}
                </div>
              </div>

              {/* 图片渠道设置 */}
              <div className="channel-section">
                <h3 className="channel-section-title">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="channel-section-icon">
                    <rect x="3" y="3" width="18" height="18" rx="2" />
                    <circle cx="8.5" cy="8.5" r="1.5" />
                    <path d="M21 15l-5-5L5 21" />
                  </svg>
                  图片生成渠道
                </h3>
                <div className="channel-list">
                  {imageCapabilities.map(cap => (
                    <div key={cap.code} className="channel-capability-group">
                      <div className="channel-capability-name">{cap.name}</div>
                      {cap.channels.map(channel => (
                        <label key={`${cap.code}-${channel.channel_type}`} className="channel-item">
                          <input
                            type="radio"
                            name="imageChannel"
                            value={channel.channel_type}
                            checked={imageSelection.channel === channel.channel_type && imageSelection.model === cap.code}
                            onChange={() => handleImageChannelSelect(cap.code, channel)}
                          />
                          <span className="channel-radio" />
                          <div className="channel-info">
                            <span className="channel-name">{channel.channel_name} - ¥{channel.price}</span>
                            <span className="channel-desc">模型: {channel.model}</span>
                          </div>
                        </label>
                      ))}
                    </div>
                  ))}
                  {imageCapabilities.length === 0 && (
                    <div className="channel-empty">暂无可用的图片渠道</div>
                  )}
                </div>
              </div>

              {/* 视频渠道设置 */}
              <div className="channel-section">
                <h3 className="channel-section-title">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="channel-section-icon">
                    <rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18" />
                    <line x1="7" y1="2" x2="7" y2="22" />
                    <line x1="17" y1="2" x2="17" y2="22" />
                    <line x1="2" y1="12" x2="22" y2="12" />
                    <line x1="2" y1="7" x2="7" y2="7" />
                    <line x1="2" y1="17" x2="7" y2="17" />
                    <line x1="17" y1="17" x2="22" y2="17" />
                    <line x1="17" y1="7" x2="22" y2="7" />
                  </svg>
                  视频生成渠道
                </h3>
                <div className="channel-list">
                  {videoCapabilities.map(cap => (
                    <div key={cap.code} className="channel-capability-group">
                      <div className="channel-capability-name">{cap.name}</div>
                      {cap.channels.map(channel => (
                        <label key={`${cap.code}-${channel.channel_type}`} className="channel-item">
                          <input
                            type="radio"
                            name="videoChannel"
                            value={channel.channel_type}
                            checked={videoSelection.channel === channel.channel_type && videoSelection.model === cap.code}
                            onChange={() => handleVideoChannelSelect(cap.code, channel)}
                          />
                          <span className="channel-radio" />
                          <div className="channel-info">
                            <span className="channel-name">{channel.channel_name} - ¥{channel.price}</span>
                            <span className="channel-desc">模型: {channel.model}</span>
                          </div>
                        </label>
                      ))}
                    </div>
                  ))}
                  {videoCapabilities.length === 0 && (
                    <div className="channel-empty">暂无可用的视频渠道</div>
                  )}
                </div>
              </div>
            </>
          )}
        </div>

        <div className="channel-modal-footer">
          <button className="channel-btn channel-btn-secondary" onClick={onClose}>
            返回
          </button>
          <button className="channel-btn channel-btn-primary" onClick={handleSave}>
            保存
          </button>
        </div>
      </div>
    </div>
  );
};

export default ChannelSettingsModal;
