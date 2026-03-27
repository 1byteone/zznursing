package com.zzyl.nursing.controller.member;

import java.util.List;
import java.util.Map;

import com.zzyl.common.core.domain.R;
import com.zzyl.common.utils.UserThreadLocal;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.zzyl.common.annotation.Log;
import com.zzyl.common.core.controller.BaseController;
import com.zzyl.common.core.domain.AjaxResult;
import com.zzyl.common.enums.BusinessType;
import com.zzyl.nursing.domain.Reservation;
import com.zzyl.nursing.service.IReservationService;
import com.zzyl.common.core.page.TableDataInfo;

/**
 * 预约信息Controller
 * 
 * @author yjs
 * @date 2026-03-27
 */
@Api("预约信息管理")
@RestController
@RequestMapping("/member/reservation")
public class MemberReservationController extends BaseController
{
    @Autowired
    private IReservationService reservationService;

    @GetMapping("/cancelled-count")
    @ApiOperation("查询取消预约数量")
    public R<Integer> getCancelledReservationCount() {
        Long userId = UserThreadLocal.getUserId();
        int count = reservationService.getCancelledReservationCount(userId);
        return R.ok(count);
    }

    @GetMapping("/countByTime")
    @ApiOperation("2.2 查询每个时间段剩余预约次数")
    public R<List<Map<String, Integer>>> countByTime() {
        Long userId = UserThreadLocal.getUserId();
        List<Map<String, Integer>> result = reservationService.countByTime();
        return R.ok(result);
    }

    /**
     * 查询预约信息列表
     */
    @ApiOperation("查询预约信息列表")
    @GetMapping("/page")
    public TableDataInfo<List<Reservation>> list(@ApiParam("查询条件对象") Reservation reservation)
    {
        startPage();
        List<Reservation> list = reservationService.selectReservationList(reservation);
        return getDataTable(list);
    }



    /**
     * 新增预约信息
     */
    @ApiOperation("新增预约信息")
    @Log(title = "预约信息", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody @ApiParam("新增的预约信息对象") Reservation reservation)
    {
        return toAjax(reservationService.insertReservation(reservation));
    }



    /**
     * 删除预约信息
     */
    @ApiOperation("删除预约信息")
    @Log(title = "预约信息", businessType = BusinessType.DELETE)
	@DeleteMapping("/{id}/cancel}")
    public AjaxResult remove(@PathVariable @ApiParam("要删除的预约信息ID") Long id)
    {
        return toAjax(reservationService.deleteReservationById(id));
    }
}
