import React, { useState, useEffect, useRef } from 'react';
import type { ProjectResource, ResourceType, ResourceStatus } from '@/api/characterProject';
import {
  updateVideoResource,
  generateCharacter,
  getVideoResource,
} from '@/api/videoResource';
import {
  createVideo,
  getTaskStatus as getVideoTaskStatus,
} from '@/api/videoGeneration';
import { showWarning, showSuccess } from '@/utils/request';
import { IMAGE_STYLES } from '@/constants/enums';

// 资源类型标签
const RESOURCE_TYPE_LABELS: Record<string, string> = {
  character: '角色',
  scene: '场景',
  prop: '道具',
  skill: '技能',
};

// 资源状态标签
const RESOURCE_STATUS_LABELS: Record<string, string> = {
  not_generated: '未生成',
  video_generating: '视频生成中',
  video_generated: '视频已生成',
  character_generating: '角色生成中',
  completed: '已完成',
  failed: '失败',
};

interface CharacterProjectResourceTableProps {
  resources: ProjectResource[];
  projectStyle?: string;
  onResourcesChange: (resources: ProjectResource[]) => void;
  onDelete?: (resourceId: number, resourceName: string) => void;
}

const CharacterProjectResourceTable: React.FC<CharacterProjectResourceTableProps> = ({
  resources,
  projectStyle,
  onResourcesChange,
  onDelete,
}) => {
  // 筛选器状态
  const [typeFilter, setTypeFilter] = useState<string>('');
  const [statusFilter, setStatusFilter] = useState<string>('');

  // 视频生成状态
  const [generatingVideoIds, setGeneratingVideoIds] = useState<Set<number>>(new Set());

  // 角色生成状态
  const [generatingCharacterIds, setGeneratingCharacterIds] = useState<Set<number>>(new Set());

  // 提示词编辑状态
  const [editingPromptId, setEditingPromptId] = useState<number | null>(null);
  const [editingPromptValue, setEditingPromptValue] = useState('');
  const [savingPrompt, setSavingPrompt] = useState(false);

  // 时间戳输入状态
  const [startTimeInput, setStartTimeInput] = useState<Record<number, string>>({});
  const [endTimeInput, setEndTimeInput] = useState<Record<number, string>>({});

  // 尺寸选择状态
  const [aspectRatioInput, setAspectRatioInput] = useState<Record<number, string>>({});

  // 预览模态框
  const [previewResource, setPreviewResource] = useState<ProjectResource | null>(null);

  // 轮询定时器引用
  const pollingTimers = useRef<Map<number, NodeJS.Timeout>>(new Map());

  // 保存最新的 resources 引用，避免闭包陷阱
  const resourcesRef = useRef(resources);
  useEffect(() => {
    resourcesRef.current = resources;
  }, [resources]);

  // 组件卸载时清理定时器
  useEffect(() => {
    return () => {
      pollingTimers.current.forEach(timer => clearTimeout(timer));
      pollingTimers.current.clear();
    };
  }, []);

  // 获取资源的默认尺寸
  const getDefaultAspectRatio = (resourceType: string): string => {
    return resourceType === 'character' ? '9:16' : '16:9';
  };

  // 获取资源的尺寸
  const getAspectRatio = (resource: ProjectResource): string => {
    return aspectRatioInput[resource.id] ?? getDefaultAspectRatio(resource.resourceType);
  };

  // 筛选资源
  const filteredResources = resources.filter((resource) => {
    if (typeFilter && resource.resourceType !== typeFilter) {
      return false;
    }
    if (statusFilter && resource.status !== statusFilter) {
      return false;
    }
    return true;
  });

  // 生成视频
  const handleGenerateVideo = async (resource: ProjectResource) => {
    if (!resource.prompt) {
      showWarning('请先填写提示词');
      return;
    }

    setGeneratingVideoIds(prev => new Set(prev).add(resource.id));

    try {
      // 更新本地状态为视频生成中
      onResourcesChange(
        resources.map(r => r.id === resource.id ? { ...r, status: 'video_generating' as ResourceStatus } : r)
      );

      // 更新数据库状态
      const aspectRatio = getAspectRatio(resource);
      await updateVideoResource(resource.id, { status: 'video_generating', aspectRatio });

      // 构建提示词：如果项目有风格，将风格提示词加在前面
      let finalPrompt = resource.prompt;
      if (projectStyle) {
        const styleOption = IMAGE_STYLES.find(s => s.value === projectStyle);
        if (styleOption?.prompt) {
          finalPrompt = `${styleOption.prompt}, ${resource.prompt}`;
        }
      }

      // 创建视频生成任务
      const result = await createVideo({
        prompt: finalPrompt,
        aspectRatio: aspectRatio as '16:9' | '9:16',
        duration: 10,
      });

      if (result.code !== 200) {
        throw new Error(result.msg || '创建任务失败');
      }

      const taskId = result.data.id;
      const videoTaskId = result.data.taskId;
      showSuccess('视频生成任务已创建，正在生成中...');

      // 更新数据库，保存 videoTaskId
      await updateVideoResource(resource.id, {
        videoTaskId: videoTaskId,
        status: 'video_generating',
      });

      // 更新本地状态
      onResourcesChange(
        resources.map(r => r.id === resource.id ? {
          ...r,
          status: 'video_generating' as ResourceStatus,
        } : r)
      );

      // 轮询任务状态
      const pollTask = async () => {
        try {
          const statusResult = await getVideoTaskStatus(taskId);
          if (statusResult.code !== 200) {
            throw new Error(statusResult.msg || '查询任务状态失败');
          }

          const task = statusResult.data;

          if (task.status === 'succeeded' && task.resultUrl) {
            // 更新数据库 - 视频生成完成
            await updateVideoResource(resource.id, {
              videoUrl: task.resultUrl,
              videoResultUrl: task.resultUrl,
              status: 'video_generated',
            });

            // 更新本地状态 - 使用 resourcesRef 避免闭包陷阱
            onResourcesChange(
              resourcesRef.current.map(r => r.id === resource.id ? {
                ...r,
                characterVideoUrl: task.resultUrl ?? undefined,
                status: 'video_generated' as ResourceStatus,
              } : r)
            );
            showSuccess('视频生成完成');
            setGeneratingVideoIds(prev => {
              const newSet = new Set(prev);
              newSet.delete(resource.id);
              return newSet;
            });
            pollingTimers.current.delete(resource.id);
          } else if (task.status === 'error') {
            // 更新数据库状态为失败
            await updateVideoResource(resource.id, {
              status: 'failed',
              errorMessage: task.errorMessage || '视频生成失败',
            });

            // 更新本地状态 - 使用 resourcesRef 避免闭包陷阱
            onResourcesChange(
              resourcesRef.current.map(r => r.id === resource.id ? {
                ...r,
                status: 'failed' as ResourceStatus,
              } : r)
            );
            showWarning('视频生成失败: ' + (task.errorMessage || '未知错误'));
            setGeneratingVideoIds(prev => {
              const newSet = new Set(prev);
              newSet.delete(resource.id);
              return newSet;
            });
            pollingTimers.current.delete(resource.id);
          } else {
            // 继续轮询
            const timer = setTimeout(pollTask, 10000);
            pollingTimers.current.set(resource.id, timer);
          }
        } catch (error) {
          console.error('轮询任务状态失败:', error);
          await updateVideoResource(resource.id, { status: 'failed' });
          onResourcesChange(
            resourcesRef.current.map(r => r.id === resource.id ? { ...r, status: 'failed' as ResourceStatus } : r)
          );
          setGeneratingVideoIds(prev => {
            const newSet = new Set(prev);
            newSet.delete(resource.id);
            return newSet;
          });
          pollingTimers.current.delete(resource.id);
        }
      };

      // 开始轮询
      const timer = setTimeout(pollTask, 5000);
      pollingTimers.current.set(resource.id, timer);

    } catch (error) {
      console.error('生成视频失败:', error);
      showWarning('生成视频失败');
      await updateVideoResource(resource.id, { status: 'not_generated' });
      onResourcesChange(
        resourcesRef.current.map(r => r.id === resource.id ? { ...r, status: 'not_generated' as ResourceStatus } : r)
      );
      setGeneratingVideoIds(prev => {
        const newSet = new Set(prev);
        newSet.delete(resource.id);
        return newSet;
      });
    }
  };

  // 生成角色
  const handleGenerateCharacter = async (resource: ProjectResource) => {
    if (!resource.characterVideoUrl) {
      showWarning('请先生成视频');
      return;
    }

    const startTime = startTimeInput[resource.id] ?? '0';
    const endTime = endTimeInput[resource.id] ?? '5';

    const startNum = parseFloat(startTime);
    const endNum = parseFloat(endTime);
    if (isNaN(startNum) || isNaN(endNum)) {
      showWarning('请输入有效的时间');
      return;
    }
    if (startNum >= endNum) {
      showWarning('开始时间必须小于结束时间');
      return;
    }

    const timestamps = `${startTime},${endTime}`;

    setGeneratingCharacterIds(prev => new Set(prev).add(resource.id));

    try {
      // 更新状态为角色生成中
      onResourcesChange(
        resourcesRef.current.map(r => r.id === resource.id ? { ...r, status: 'character_generating' as ResourceStatus } : r)
      );

      // 调用角色生成 API
      const result = await generateCharacter({
        resourceId: resource.id,
        videoUrl: resource.characterVideoUrl,
        timestamps: timestamps,
      });

      if (result.code !== 200) {
        throw new Error(result.msg || '创建角色生成任务失败');
      }

      showSuccess('角色生成任务已创建');

      // 开始轮询资源状态
      const pollResource = async () => {
        try {
          const resourceResult = await getVideoResource(resource.id);
          if (resourceResult.code !== 200) {
            throw new Error(resourceResult.msg || '查询资源状态失败');
          }

          const updatedResource = resourceResult.data;

          if (updatedResource.status === 'completed') {
            // 更新本地状态 - 使用 resourcesRef 避免闭包陷阱
            onResourcesChange(
              resourcesRef.current.map(r => r.id === resource.id ? {
                ...r,
                characterId: updatedResource.characterId || undefined,
                characterImageUrl: updatedResource.characterImageUrl || undefined,
                status: 'completed' as ResourceStatus,
              } : r)
            );
            showSuccess('角色生成完成');
            setGeneratingCharacterIds(prev => {
              const newSet = new Set(prev);
              newSet.delete(resource.id);
              return newSet;
            });
            pollingTimers.current.delete(resource.id);
          } else if (updatedResource.status === 'failed') {
            onResourcesChange(
              resourcesRef.current.map(r => r.id === resource.id ? { ...r, status: 'failed' as ResourceStatus } : r)
            );
            showWarning('角色生成失败');
            setGeneratingCharacterIds(prev => {
              const newSet = new Set(prev);
              newSet.delete(resource.id);
              return newSet;
            });
            pollingTimers.current.delete(resource.id);
          } else {
            // 继续轮询
            const timer = setTimeout(pollResource, 10000);
            pollingTimers.current.set(resource.id, timer);
          }
        } catch (error) {
          console.error('轮询资源状态失败:', error);
          setGeneratingCharacterIds(prev => {
            const newSet = new Set(prev);
            newSet.delete(resource.id);
            return newSet;
          });
          pollingTimers.current.delete(resource.id);
        }
      };

      // 开始轮询
      const timer = setTimeout(pollResource, 5000);
      pollingTimers.current.set(resource.id, timer);

    } catch (error) {
      console.error('生成角色失败:', error);
      showWarning('生成角色失败');
      onResourcesChange(
        resourcesRef.current.map(r => r.id === resource.id ? { ...r, status: 'failed' as ResourceStatus } : r)
      );
      setGeneratingCharacterIds(prev => {
        const newSet = new Set(prev);
        newSet.delete(resource.id);
        return newSet;
      });
    }
  };

  // 开始编辑提示词
  const handleStartEditPrompt = (resource: ProjectResource) => {
    setEditingPromptId(resource.id);
    setEditingPromptValue(resource.prompt || '');
  };

  // 取消编辑提示词
  const handleCancelEditPrompt = () => {
    setEditingPromptId(null);
    setEditingPromptValue('');
  };

  // 保存提示词
  const handleSavePrompt = async (resourceId: number) => {
    setSavingPrompt(true);
    try {
      await updateVideoResource(resourceId, { prompt: editingPromptValue });
      onResourcesChange(
        resources.map(r => r.id === resourceId ? { ...r, prompt: editingPromptValue } : r)
      );
      setEditingPromptId(null);
      setEditingPromptValue('');
      showSuccess('提示词已保存');
    } catch (error) {
      console.error('保存提示词失败:', error);
      showWarning('保存提示词失败');
    } finally {
      setSavingPrompt(false);
    }
  };

  // 判断是否可以生成角色
  const canGenerateCharacter = (resource: ProjectResource) => {
    return resource.characterVideoUrl &&
           resource.status !== 'video_generating' &&
           resource.status !== 'character_generating';
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString('zh-CN', {
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  return (
    <>
      {/* 筛选器 */}
      <div className="cpd-filters">
        <select
          className="cpd-filter-select"
          value={typeFilter}
          onChange={(e) => setTypeFilter(e.target.value)}
        >
          <option value="">全部类型</option>
          <option value="character">角色</option>
          <option value="scene">场景</option>
          <option value="prop">道具</option>
          <option value="skill">技能</option>
        </select>

        <select
          className="cpd-filter-select"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
        >
          <option value="">全部状态</option>
          <option value="not_generated">未生成</option>
          <option value="video_generating">视频生成中</option>
          <option value="video_generated">视频已生成</option>
          <option value="character_generating">角色生成中</option>
          <option value="completed">已完成</option>
          <option value="failed">失败</option>
        </select>
      </div>

      {/* 资源列表 */}
      {filteredResources.length === 0 ? (
        <div className="cpd-empty">
          <div className="cpd-empty-icon">📦</div>
          <p>暂无资源，点击"提取资源"或"从剧本选择"添加资源</p>
        </div>
      ) : (
        <div className="cpd-resource-table-container">
          <table className="cpd-resource-table">
            <thead>
              <tr>
                <th>预览</th>
                <th>名称</th>
                <th>类型</th>
                <th>状态</th>
                <th>提示词</th>
                <th>尺寸</th>
                <th>开始(秒)</th>
                <th>结束(秒)</th>
                <th>创建时间</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {filteredResources.map((resource) => (
                <tr key={resource.id}>
                  {/* 预览 */}
                  <td>
                    <div
                      className={`cpd-resource-thumbnail ${resource.characterVideoUrl || resource.characterImageUrl ? 'clickable' : ''}`}
                      onClick={() => (resource.characterVideoUrl || resource.characterImageUrl) && setPreviewResource(resource)}
                    >
                      {resource.characterImageUrl ? (
                        <img src={resource.characterImageUrl} alt={resource.resourceName} />
                      ) : resource.characterVideoUrl ? (
                        <video src={resource.characterVideoUrl} />
                      ) : (
                        <div className="cpd-resource-no-preview">
                          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
                            <polygon points="10 8 16 12 10 16 10 8" />
                          </svg>
                        </div>
                      )}
                    </div>
                  </td>

                  {/* 名称 */}
                  <td className="cpd-resource-name-cell">{resource.resourceName}</td>

                  {/* 类型 */}
                  <td>
                    <span className={`cpd-resource-type ${resource.resourceType}`}>
                      {RESOURCE_TYPE_LABELS[resource.resourceType] || resource.resourceType}
                    </span>
                  </td>

                  {/* 状态 */}
                  <td>
                    <span className={`cpd-status-badge ${resource.status}`}>
                      {RESOURCE_STATUS_LABELS[resource.status] || resource.status}
                    </span>
                  </td>

                  {/* 提示词 */}
                  <td className="cpd-resource-prompt-cell">
                    {editingPromptId === resource.id ? (
                      <div className="cpd-prompt-edit">
                        <textarea
                          className="cpd-prompt-textarea"
                          value={editingPromptValue}
                          onChange={(e) => setEditingPromptValue(e.target.value)}
                          placeholder="输入提示词..."
                          rows={3}
                          autoFocus
                        />
                        <div className="cpd-prompt-actions">
                          <button
                            className="cpd-prompt-btn save"
                            onClick={() => handleSavePrompt(resource.id)}
                            disabled={savingPrompt}
                          >
                            {savingPrompt ? '...' : '保存'}
                          </button>
                          <button
                            className="cpd-prompt-btn cancel"
                            onClick={handleCancelEditPrompt}
                            disabled={savingPrompt}
                          >
                            取消
                          </button>
                        </div>
                      </div>
                    ) : (
                      <div
                        className="cpd-prompt-display"
                        onClick={() => handleStartEditPrompt(resource)}
                        title="点击编辑提示词"
                      >
                        {resource.prompt ? (
                          <span className="cpd-prompt-text">
                            {resource.prompt.length > 50 ? resource.prompt.slice(0, 50) + '...' : resource.prompt}
                          </span>
                        ) : (
                          <span className="cpd-prompt-empty">点击添加提示词</span>
                        )}
                        <svg className="cpd-prompt-edit-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
                        </svg>
                      </div>
                    )}
                  </td>

                  {/* 尺寸 */}
                  <td className="cpd-resource-aspect-cell">
                    <select
                      className="cpd-aspect-select"
                      value={getAspectRatio(resource)}
                      onChange={(e) => setAspectRatioInput({
                        ...aspectRatioInput,
                        [resource.id]: e.target.value,
                      })}
                      disabled={resource.status === 'video_generating'}
                    >
                      <option value="16:9">横版</option>
                      <option value="9:16">竖版</option>
                    </select>
                  </td>

                  {/* 开始时间 */}
                  <td className="cpd-resource-time-cell">
                    {resource.characterVideoUrl ? (
                      <input
                        type="number"
                        className="cpd-time-input"
                        placeholder="0"
                        step="0.1"
                        min="0"
                        value={startTimeInput[resource.id] ?? ''}
                        onChange={(e) => setStartTimeInput({
                          ...startTimeInput,
                          [resource.id]: e.target.value,
                        })}
                      />
                    ) : (
                      <span className="cpd-no-time">-</span>
                    )}
                  </td>

                  {/* 结束时间 */}
                  <td className="cpd-resource-time-cell">
                    {resource.characterVideoUrl ? (
                      <input
                        type="number"
                        className="cpd-time-input"
                        placeholder="5"
                        step="0.1"
                        min="0"
                        value={endTimeInput[resource.id] ?? ''}
                        onChange={(e) => setEndTimeInput({
                          ...endTimeInput,
                          [resource.id]: e.target.value,
                        })}
                      />
                    ) : (
                      <span className="cpd-no-time">-</span>
                    )}
                  </td>

                  {/* 创建时间 */}
                  <td className="cpd-resource-date">{formatDate(resource.createdAt)}</td>

                  {/* 操作 */}
                  <td className="cpd-resource-actions-cell">
                    <div className="cpd-resource-action-group">
                      {/* 视频创作按钮 */}
                      {resource.prompt && (
                        <button
                          className="cpd-action-btn video"
                          onClick={() => handleGenerateVideo(resource)}
                          disabled={generatingVideoIds.has(resource.id) || resource.status === 'video_generating'}
                          title="生成视频"
                        >
                          {generatingVideoIds.has(resource.id) || resource.status === 'video_generating' ? (
                            <>
                              <span className="cpd-btn-spinner"></span>
                              生成中
                            </>
                          ) : resource.characterVideoUrl ? (
                            '重新生成'
                          ) : (
                            '视频创作'
                          )}
                        </button>
                      )}

                      {/* 角色创作按钮 */}
                      {canGenerateCharacter(resource) && (
                        <button
                          className="cpd-action-btn character"
                          onClick={() => handleGenerateCharacter(resource)}
                          disabled={generatingCharacterIds.has(resource.id)}
                          title="从视频生成角色"
                        >
                          {generatingCharacterIds.has(resource.id) || resource.status === 'character_generating' ? (
                            <>
                              <span className="cpd-btn-spinner"></span>
                              生成中
                            </>
                          ) : resource.characterId ? (
                            '重新生成'
                          ) : (
                            '角色创作'
                          )}
                        </button>
                      )}

                      {/* 删除按钮 */}
                      {onDelete && (
                        <button
                          className="cpd-action-btn delete"
                          onClick={() => onDelete(resource.id, resource.resourceName)}
                          title="删除"
                        >
                          删除
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* 预览模态框 */}
      {previewResource && (
        <div className="cpd-preview-overlay" onClick={() => setPreviewResource(null)}>
          <div className="cpd-preview-container" onClick={(e) => e.stopPropagation()}>
            <button className="cpd-preview-close" onClick={() => setPreviewResource(null)}>
              ×
            </button>
            {previewResource.characterImageUrl ? (
              <img
                src={previewResource.characterImageUrl}
                alt={previewResource.resourceName}
                className="cpd-preview-image"
              />
            ) : previewResource.characterVideoUrl ? (
              <video
                src={previewResource.characterVideoUrl}
                controls
                autoPlay
                className="cpd-preview-video"
              />
            ) : null}
            <div className="cpd-preview-info">
              <h3>{previewResource.resourceName}</h3>
              <span className={`cpd-resource-type ${previewResource.resourceType}`}>
                {RESOURCE_TYPE_LABELS[previewResource.resourceType]}
              </span>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default CharacterProjectResourceTable;
