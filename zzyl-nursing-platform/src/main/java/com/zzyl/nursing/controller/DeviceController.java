package com.zzyl.nursing.controller;

import java.util.List;
import javax.servlet.http.HttpServletResponse;

import com.zzyl.common.core.domain.R;
import com.zzyl.nursing.dto.DeviceDto;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.zzyl.common.annotation.Log;
import com.zzyl.common.core.controller.BaseController;
import com.zzyl.common.core.domain.AjaxResult;
import com.zzyl.common.enums.BusinessType;
import com.zzyl.nursing.domain.Device;
import com.zzyl.nursing.service.IDeviceService;
import com.zzyl.common.utils.poi.ExcelUtil;
import com.zzyl.common.core.page.TableDataInfo;

/**
 * 设备表Controller
 * 
 * @author yjs
 * @date 2026-03-25
 */
@Api("设备表管理")
@RestController
@RequestMapping("/nursing/device")
public class DeviceController extends BaseController
{
    @Autowired
    private IDeviceService deviceService;

    /**
     * 查询设备表列表
     */
    @ApiOperation("查询设备表列表")
    @PreAuthorize("@ss.hasPermi('nursing:device:list')")
    @GetMapping("/list")
    public TableDataInfo<List<Device>> list(@ApiParam("查询条件对象") Device device)
    {
        startPage();
        List<Device> list = deviceService.selectDeviceList(device);
        return getDataTable(list);
    }

    /**
     * 从物联网平台同步产品列表
     */
    @PostMapping("/syncProductList")
    @ApiOperation(value = "从物联网平台同步产品列表")
    public AjaxResult syncProductList(){
        deviceService.syncProductList();
        return success();
    }

    /**
     * 查询所有产品列表
     */
    @GetMapping("/allProduct")
    @ApiOperation(value = "查询所有产品列表")
    public AjaxResult allProduct() {
        return success(deviceService.allProduct());
    }

    /**
     * 注册设备
     */
    @PostMapping("/register")
    @ApiOperation(value = "注册设备")
    public AjaxResult registerDevice(@RequestBody DeviceDto deviceDto) {
        deviceService.registerDevice(deviceDto);
        return success();
    }

    /**
     * 获取设备详细信息
     */
    @GetMapping("/{iotId}")
    @ApiOperation("获取设备详细信息")
    public AjaxResult getInfo(@PathVariable("iotId") String iotId) {
        return success(deviceService.queryDeviceDetail(iotId));
    }

    /**
     * 查询设备上报数据
     */
    @GetMapping("/queryServiceProperties/{iotId}")
    @ApiOperation("查询设备上报数据")
    public AjaxResult queryServiceProperties(@PathVariable("iotId") String iotId) {
        AjaxResult ajaxResult = deviceService.queryServiceProperties(iotId);
        return ajaxResult;
    }

    /**
     * 自定义更新设备信息
     */
    @PutMapping
    @ApiOperation("更新设备信息")
    public AjaxResult editDevice(@RequestBody DeviceDto dto){
        deviceService.customUpdateDevice(dto);
        return success();
    }

    @DeleteMapping("/{iotId}")
    @ApiOperation("删除设备")
    public AjaxResult deleteDevice(@PathVariable("iotId") String iotId){
        deviceService.customDeleteDeviceById(iotId);
        return success();
    }

    @GetMapping("/queryProduct/{productKey}")
    @ApiOperation(value = "查询产品详情")
    public AjaxResult queryProduct(@PathVariable String productKey) {
        return deviceService.queryProduct(productKey);
    }
}
