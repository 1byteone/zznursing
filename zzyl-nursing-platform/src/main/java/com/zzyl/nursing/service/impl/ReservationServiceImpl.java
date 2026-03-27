package com.zzyl.nursing.service.impl;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import cn.hutool.core.date.LocalDateTimeUtil;
import com.zzyl.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.zzyl.nursing.mapper.ReservationMapper;
import com.zzyl.nursing.domain.Reservation;
import com.zzyl.nursing.service.IReservationService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

/**
 * 预约信息Service业务层处理
 * 
 * @author yjs
 * @date 2026-03-27
 */
@Service
public class ReservationServiceImpl extends ServiceImpl<ReservationMapper, Reservation> implements IReservationService
{
    @Autowired
    private ReservationMapper reservationMapper;

    /**
     * 查询预约信息
     * 
     * @param id 预约信息主键
     * @return 预约信息
     */
    @Override
    public Reservation selectReservationById(Long id)
    {
        return getById(id);
    }

    /**
     * 查询预约信息列表
     * 
     * @param reservation 预约信息
     * @return 预约信息
     */
    @Override
    public List<Reservation> selectReservationList(Reservation reservation)
    {
        return reservationMapper.selectReservationList(reservation);
    }

    /**
     * 新增预约信息
     * 
     * @param reservation 预约信息
     * @return 结果
     */
    @Override
    public int insertReservation(Reservation reservation)
    {
        return save(reservation) ? 1 : 0;
    }

    /**
     * 修改预约信息
     * 
     * @param reservation 预约信息
     * @return 结果
     */
    @Override
    public int updateReservation(Reservation reservation)
    {
        return updateById(reservation) ? 1 : 0;
    }

    /**
     * 批量删除预约信息
     * 
     * @param ids 需要删除的预约信息主键
     * @return 结果
     */
    @Override
    public int deleteReservationByIds(Long[] ids)
    {
        return removeByIds(Arrays.asList(ids)) ? 1 : 0;
    }

    /**
     * 删除预约信息信息
     * 
     * @param id 预约信息主键
     * @return 结果
     */
    @Override
    public int deleteReservationById(Long id)
    {
        return removeById(id) ? 1 : 0;
    }


    /**
     * 查询取消预约数量
     *
     * @param userId 用户ID
     * @return 取消预约数量
     */
    @Override
    public int getCancelledReservationCount(Long userId) {
        long time = System.currentTimeMillis();
        LocalDateTime ldt = LocalDateTimeUtil.of(time);
        LocalDateTime startTime = ldt.toLocalDate().atStartOfDay();
        LocalDateTime endTime = startTime.plusDays(1);
        return reservationMapper.getCancelledReservationCount(userId, startTime, endTime);
    }

    /**
     * 查询每个时间段剩余预约次数
     *
     * @return 预约信息
     */
    @Override
    public List<Map<String, Integer>> countByTime() {
        long time = System.currentTimeMillis();
        LocalDateTime ldt = LocalDateTimeUtil.of(time);
        LocalDateTime startTime = ldt.toLocalDate().atStartOfDay();
        LocalDateTime endTime = startTime.plusDays(1);
        return reservationMapper.countByTime(startTime, endTime);
    }
}
