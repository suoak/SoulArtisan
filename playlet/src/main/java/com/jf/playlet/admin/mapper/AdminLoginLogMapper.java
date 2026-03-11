package com.jf.playlet.admin.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jf.playlet.admin.entity.AdminLoginLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 管理员登录日志表 Mapper
 */
@Mapper
public interface AdminLoginLogMapper extends BaseMapper<AdminLoginLog> {

}
