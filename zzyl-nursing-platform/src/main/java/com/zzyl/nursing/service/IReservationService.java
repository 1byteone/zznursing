package com.zzyl.nursing.service;

import java.util.List;
import java.util.Map;

import com.zzyl.nursing.domain.Reservation;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 预约信息Service接口
 * 
 * @author yjs
 * @date 2026-03-27
 */
public interface IReservationService extends IService<Reservation>
{
    /**
     * 查询预约信息
     * 
     * @param id 预约信息主键
     * @return 预约信息
     */
    public Reservation selectReservationById(Long id);

    /**
     * 查询预约信息列表
     * 
     * @param reservation 预约信息
     * @return 预约信息集合
     */
    public List<Reservation> selectReservationList(Reservation reservation);

    /**
     * 新增预约信息
     * 
     * @param reservation 预约信息
     * @return 结果
     */
    public int insertReservation(Reservation reservation);

    /**
     * 修改预约信息
     * 
     * @param reservation 预约信息
     * @return 结果
     */
    public int updateReservation(Reservation reservation);

    /**
     * 批量删除预约信息
     * 
     * @param ids 需要删除的预约信息主键集合
     * @return 结果
     */
    public int deleteReservationByIds(Long[] ids);

    /**
     * 删除预约信息信息
     * 
     * @param id 预约信息主键
     * @return 结果
     */
    public int deleteReservationById(Long id);

    /**
     * 查询取消预约数量
     * @param userId
     * @return
     */
    int getCancelledReservationCount(Long userId);

    /**
     * 查询每个时间段剩余预约次数
     * @return
     */
    List<Map<String, Integer>> countByTime();
}
