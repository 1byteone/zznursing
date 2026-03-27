package com.zzyl.nursing.mapper;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import com.zzyl.nursing.domain.Reservation;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 预约信息Mapper接口
 * 
 * @author yjs
 * @date 2026-03-27
 */
@Mapper
public interface ReservationMapper extends BaseMapper<Reservation>
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
     * 删除预约信息
     * 
     * @param id 预约信息主键
     * @return 结果
     */
    public int deleteReservationById(Long id);

    /**
     * 批量删除预约信息
     * 
     * @param ids 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteReservationByIds(Long[] ids);

    @Select("select count(1) from reservation where status = 2 and update_by = #{userId} and update_time between #{startTime} and #{endTime}")
    int getCancelledReservationCount(@Param("userId") Long userId, @Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);

    @Select("select time, 6 - count(1) as count from reservation where status ! 2 and `time` between #{startTime} and #{endTime}  group by `time`")
    List<Map<String, Integer>> countByTime(@Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);
}
