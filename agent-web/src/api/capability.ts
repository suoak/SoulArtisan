/**
 * 能力渠道 API 封装
 */

import { get } from '../utils/request';

// 类型定义
export interface ChannelInfo {
    channel_name: string;
    channel_type: string;
    model: string;
    price: number;
}

export interface CapabilityInfo {
    channels: ChannelInfo[];
    code: string;
    description: string;
    name: string;
    type: 'image' | 'video';
}

export interface ApiResponse<T = any> {
    code: number;
    msg: string;
    data: T;
}

// 对话模型类型
export interface ChatModelInfo {
    id: string;
    object: string;
    created: number;
    owned_by: string;
}

// API 方法

/**
 * 获取能力渠道列表
 */
export const getCapabilities = async (): Promise<ApiResponse<CapabilityInfo[]>> => {
    const response = await get<ApiResponse<CapabilityInfo[]>>('/api/capabilities');
    return response.data;
};

/**
 * 获取对话模型列表
 */
export const getChatModelList = async (): Promise<ApiResponse<ChatModelInfo[]>> => {
    const response = await get<ApiResponse<ChatModelInfo[]>>('/api/capabilities/chatModels');
    return response.data;
};

export default {
    getCapabilities,
    getChatModelList,
};
