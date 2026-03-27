package com.zzyl.nursing.service;

import java.util.List;

import com.zzyl.common.core.domain.AjaxResult;
import com.zzyl.nursing.domain.Device;
import com.baomidou.mybatisplus.extension.service.IService;
import com.zzyl.nursing.dto.DeviceDto;
import com.zzyl.nursing.vo.DeviceDetailVo;
import com.zzyl.nursing.vo.ProductVo;

/**
 * 设备表Service接口
 * 
 * @author yjs
 * @date 2026-03-25
 */
public interface IDeviceService extends IService<Device>
{
    /**
     * 查询设备表
     * 
     * @param id 设备表主键
     * @return 设备表
     */
    public Device selectDeviceById(Long id);

    /**
     * 查询设备表列表
     * 
     * @param device 设备表
     * @return 设备表集合
     */
    public List<Device> selectDeviceList(Device device);

    /**
     * 新增设备表
     * 
     * @param device 设备表
     * @return 结果
     */
    public int insertDevice(Device device);

    /**
     * 修改设备表
     * 
     * @param device 设备表
     * @return 结果
     */
    public int updateDevice(Device device);

    /**
     * 批量删除设备表
     * 
     * @param ids 需要删除的设备表主键集合
     * @return 结果
     */
    public int deleteDeviceByIds(Long[] ids);

    /**
     * 删除设备表信息
     * 
     * @param id 设备表主键
     * @return 结果
     */
    public int deleteDeviceById(Long id);

    /**
     * 从物联网平台同步产品列表
     */
    void syncProductList();

    /**
     * 查询所有产品列表
     *
     * @return 产品列表
     */
    List<ProductVo> allProduct();

    /**
     * 注册设备
     * @param deviceDto
     */
    void registerDevice(DeviceDto deviceDto);

    /**
     * 查询设备详情
     * @param iotId
     * @return
     */
    DeviceDetailVo queryDeviceDetail(String iotId);

    /**
     * 查询设备上报数据
     * @param iotId
     * @return
     */
    AjaxResult queryServiceProperties(String iotId);

    /**
     * 自定义更新设备
     * @param dto
     */
    void customUpdateDevice(DeviceDto dto);

    /**
     * 自定义删除设备
     * @param iotId
     */
    void customDeleteDeviceById(String iotId);
}
