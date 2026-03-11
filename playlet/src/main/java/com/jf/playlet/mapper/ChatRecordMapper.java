package com.jf.playlet.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jf.playlet.entity.ChatRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * AI聊天记录 Mapper
 */
@Mapper
public interface ChatRecordMapper extends BaseMapper<ChatRecord> {
}
