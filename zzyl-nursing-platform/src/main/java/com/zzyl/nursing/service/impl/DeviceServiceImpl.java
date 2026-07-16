package com.zzyl.nursing.service.impl;

import java.time.LocalDateTime;
import java.util.*;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.date.DatePattern;
import cn.hutool.core.date.LocalDateTimeUtil;
import cn.hutool.core.lang.UUID;
import cn.hutool.core.util.ObjectUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.huaweicloud.sdk.core.utils.JsonUtils;
import com.huaweicloud.sdk.iotda.v5.IoTDAClient;
import com.huaweicloud.sdk.iotda.v5.model.*;
import com.zzyl.common.constant.CacheConstants;
import com.zzyl.common.core.domain.AjaxResult;
import com.zzyl.common.exception.base.BaseException;
import com.zzyl.common.utils.DateTimeZoneConverter;
import com.zzyl.common.utils.DateUtils;
import com.zzyl.common.utils.StringUtils;
import com.zzyl.nursing.dto.DeviceDto;
import com.zzyl.nursing.vo.DeviceDetailVo;
import com.zzyl.nursing.vo.ProductVo;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import com.zzyl.nursing.mapper.DeviceMapper;
import com.zzyl.nursing.domain.Device;
import com.zzyl.nursing.service.IDeviceService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

/**
 * 设备表Service业务层处理
 * 
 * @author yjs
 * @date 2026-03-25
 */
@Service
public class DeviceServiceImpl extends ServiceImpl<DeviceMapper, Device> implements IDeviceService
{
    @Autowired
    private DeviceMapper deviceMapper;

    /**
     * 查询设备表
     * 
     * @param id 设备表主键
     * @return 设备表
     */
    @Override
    public Device selectDeviceById(Long id)
    {
        return getById(id);
    }

    /**
     * 查询设备表列表
     * 
     * @param device 设备表
     * @return 设备表
     */
    @Override
    public List<Device> selectDeviceList(Device device)
    {
        return deviceMapper.selectDeviceList(device);
    }

    /**
     * 新增设备表
     * 
     * @param device 设备表
     * @return 结果
     */
    @Override
    public int insertDevice(Device device)
    {
        return save(device) ? 1 : 0;
    }

    /**
     * 修改设备表
     * 
     * @param device 设备表
     * @return 结果
     */
    @Override
    public int updateDevice(Device device)
    {
        return updateById(device) ? 1 : 0;
    }

    /**
     * 批量删除设备表
     * 
     * @param ids 需要删除的设备表主键
     * @return 结果
     */
    @Override
    public int deleteDeviceByIds(Long[] ids)
    {
        return removeByIds(Arrays.asList(ids)) ? 1 : 0;
    }

    /**
     * 删除设备表信息
     * 
     * @param id 设备表主键
     * @return 结果
     */
    @Override
    public int deleteDeviceById(Long id)
    {
        return removeById(id) ? 1 : 0;
    }

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Autowired
    private IoTDAClient iotDAClient;

    /**
     * 同步产品列表
     */
    @Override
    public void syncProductList()
    {
        //请求参数
        ListProductsRequest listProductsRequest = new ListProductsRequest();
        //设置条数
        listProductsRequest.setLimit(50);
        //发送请求
        ListProductsResponse listProductsResponse = iotDAClient.listProducts(listProductsRequest);
        if(listProductsResponse.getHttpStatusCode()!=200){
            throw new BaseException("物联网接口 - 查询产品，同步失败");
        }
        //存储到redis
        redisTemplate.opsForValue().set(CacheConstants.IOT_ALL_PRODUCT_LIST, JSONUtil.toJsonStr(listProductsResponse.getProducts()));
    }


    /**
     * 查询所有产品列表
     * @return
     */
    @Override
    public List<ProductVo> allProduct() {
        //从redis中获取数据
        String jsonStr = redisTemplate.opsForValue().get(CacheConstants.IOT_ALL_PRODUCT_LIST);
        //如果数据为空，则返回一个空集合
        if(StringUtils.isEmpty(jsonStr)){
            return Collections.emptyList() ;
        }
        //解析数据返回
        return JSONUtil.toList(jsonStr, ProductVo.class);
    }

    /**
     * 注册设备
     * @param dto
     */
    @Override
    public void registerDevice(DeviceDto dto) {
        //判断设备名称是否存在
        Long count = count(Wrappers.<Device>lambdaQuery().eq(Device::getDeviceName, dto.getDeviceName()));
        if(count > 0) {
            throw new BaseException("设备名称已存在，请重新输入");
        }

        // 判断设备标识是否存在
        count = count(Wrappers.<Device>lambdaQuery().eq(Device::getNodeId, dto.getNodeId()));
        if(count > 0) {
            throw new BaseException("设备标识码已存在，请重新输入");
        }

        //判断同一位置是否绑定了相同的产品
        count = count(Wrappers.<Device>lambdaQuery()
                .eq(Device::getProductKey, dto.getProductKey())
                .eq(Device::getBindingLocation, dto.getBindingLocation())
                .eq(Device::getLocationType, dto.getLocationType())
                .eq(dto.getPhysicalLocationType() != null, Device::getPhysicalLocationType, dto.getPhysicalLocationType()));
        if(count > 0) {
            throw new BaseException("该老人/位置已绑定该产品，请重新选择");
        }

        //注册设备 ---》IOT平台
        AddDeviceRequest request = new AddDeviceRequest();
        AddDevice body = new AddDevice();
        body.withProductId(dto.getProductKey());
        body.withDeviceName(dto.getDeviceName());
        body.withNodeId(dto.getNodeId());

        //秘钥设置
        AuthInfo authInfo = new AuthInfo();
        String secret = UUID.randomUUID().toString().replace("-", "");
        authInfo.withSecret(secret);
        body.withAuthInfo(authInfo);
        request.withBody(body);

        AddDeviceResponse response;
        try {
            response = iotDAClient.addDevice(request);
        } catch (Exception e) {
            throw new BaseException("物联网接口 - 注册设备，同步失败");
        }
        //本地保存设备
        //属性拷贝
        Device device = BeanUtil.toBean(dto, Device.class);
        //秘钥
        device.setSecret(secret);
        //设备id，设备绑定状态
        device.setIotId(response.getDeviceId());
        save( device);
    }

    /**
     * 查询设备详情
     * @param iotId
     * @return
     */
    @Override
    public DeviceDetailVo queryDeviceDetail(String iotId) {
        //查询本地设备数据
        Device device = getOne(Wrappers.<Device>lambdaQuery().eq(Device::getIotId, iotId));
        if(ObjectUtil.isEmpty( device)){
            return null;
        }
        //调用华为云接口查询设备详情
        ShowDeviceRequest request = new ShowDeviceRequest();
        request.setDeviceId(iotId);
        ShowDeviceResponse response;
        try {
            response = iotDAClient.showDevice(request);
        }catch (Exception e){
            throw new BaseException("物联网接口 - 查询设备详情，同步失败");
        }
        //属性拷贝
        DeviceDetailVo vo = BeanUtil.toBean(device, DeviceDetailVo.class);
        vo.setDeviceStatus(response.getStatus());
        String activeTimeStr = response.getActiveTime();
        //日期转换
        if(StringUtils.isNotEmpty(activeTimeStr)) {
            //把字符串转换成LocalDateTime
            LocalDateTime activeTime = LocalDateTimeUtil.parse(activeTimeStr, DatePattern.UTC_MS_PATTERN);
            // 日期时区转换
            vo.setActiveTime(DateTimeZoneConverter.utcToShanghai(activeTime));
        }
        return vo;
    }

    /**
     * 查询设备服务属性
     * @param iotId
     * @return
     */
    @Override
    public AjaxResult queryServiceProperties(String iotId) {
        ShowDeviceShadowRequest request = new ShowDeviceShadowRequest();
        request.setDeviceId(iotId);
        ShowDeviceShadowResponse response= iotDAClient.showDeviceShadow(request);
        if(response.getHttpStatusCode()!=200){
            throw new BaseException("物联网接口 - 查询设备影子，调用失败");
        }
        List<DeviceShadowData> shadow = response.getShadow();
        if(CollUtil.isEmpty( shadow)){
            List<Object> emptyList = Collections.emptyList();
            return AjaxResult.success(emptyList);
        }
        //获取上报数据的reported (参考返回的json数据)
        DeviceShadowProperties reported = shadow.get(0).getReported();
        // 把数据转换为JSONObject(map)，方便处理
        JSONObject jsonObject = JSONUtil.parseObj(reported.getProperties());
        // 遍历数据，封装到list中
        List<Map<String,Object>>  list = new ArrayList<>();
        // 事件上报时间
        String eventTimeStr = reported.getEventTime();
        // 把字符串转换为LocalDateTime
        LocalDateTime eventTimeLocalDateTime = LocalDateTimeUtil.parse(eventTimeStr, "yyyyMMdd'T'HHmmss'Z'");
        // 时区转换
        LocalDateTime eventTime = DateTimeZoneConverter.utcToShanghai(eventTimeLocalDateTime);

        // k:属性标识，v:属性值
        jsonObject.forEach((k,v)->{
            Map<String,Object> map = new HashMap<>();
            map.put("functionId", k);
            map.put("value", v);
            map.put("eventTime", eventTime);
            list.add(map);
        });

        //数据返回
        return AjaxResult.success(list);

    }

    @Override
    public void customUpdateDevice(DeviceDto dto) {
        //先修改IoTDA平台上的设备名称
        UpdateDeviceRequest request = new UpdateDeviceRequest();
        request.withDeviceId(dto.getIotId());
        UpdateDevice body = new UpdateDevice();
        body.withDescription(dto.getDeviceDescription());
        body.withDeviceName(dto.getDeviceName());
        request.withBody(body);
        try{
            UpdateDeviceResponse response = iotDAClient.updateDevice(request);
        }catch (Exception e){
            throw new BaseException("物联网接口 - 修改设备信息，同步失败");
        }
        //注意：修改之后，不能在同一个位置绑定同一个产品
        Long count = count(Wrappers.<Device>lambdaQuery()
                .eq(Device::getProductKey, dto.getProductKey())
                .eq(Device::getBindingLocation, dto.getBindingLocation())
                .eq(Device::getLocationType, dto.getLocationType())
                .ne(Device::getIotId, dto.getIotId())
                .eq(dto.getPhysicalLocationType() != null, Device::getPhysicalLocationType, dto.getPhysicalLocationType()));
        if(count > 0){
            throw new BaseException("该位置已绑定该产品，请重新选择");
        }

        //再修改本地存储的设备信息
        Device device = getOne(Wrappers.<Device>lambdaQuery().eq(Device::getIotId, dto.getIotId()));
        if(device == null) {
            throw new BaseException("设备不存在");
        }
        BeanUtil.copyProperties(dto, device);
        updateById(device);
    }

    /**
     * 自定义删除设备
     * @param iotId 物联网设备 ID
     */
    @Override
    public void customDeleteDeviceById(String iotId) {
        //1. 查询设备信息，检查设备是否存在
        Device device = getOne(Wrappers.<Device>lambdaQuery().eq(Device::getIotId, iotId));
        if(device == null) {
            throw new BaseException("设备不存在");
        }
        
        //2. 先从 IoTDA 平台删除设备
        DeleteDeviceRequest request = new DeleteDeviceRequest();
        request.withDeviceId(iotId);
        try{
            DeleteDeviceResponse response = iotDAClient.deleteDevice(request);
            // 检查删除响应状态
            if(response.getHttpStatusCode() != 200 && response.getHttpStatusCode() != 204) {
                throw new BaseException("物联网接口 - 删除设备失败，设备可能不存在或已删除");
            }
        } catch (Exception e) {
            throw new BaseException("物联网接口 - 删除设备，同步失败：" + e.getMessage());
        }
        
        //3. 再删除本地存储的设备（使用主键 ID 删除）
        boolean removed = removeById(device.getId());
        if(!removed) {
            throw new BaseException("删除本地设备信息失败");
        }
    }

    /**
     * 查询产品详情
     * @param productKey
     * @return
     */
    @Override
    public AjaxResult queryProduct(String productKey) {
        //参数校验
        if(ObjectUtil.isEmpty(productKey)){
            throw new BaseException("参数错误,请输入正确的参数");
        }
        //调用华为云IOT平台接口
        ShowProductRequest request = new ShowProductRequest();
        request.withProductId(productKey);
        ShowProductResponse response ;

        try{
            response = iotDAClient.showProduct(request);
        } catch (Exception e) {
            throw new BaseException("查询产品详情失败");
        }

        //判断是否存在服务数据
        List<ServiceCapability> serviceCapabilities = response.getServiceCapabilities();
        if(CollUtil.isEmpty(serviceCapabilities)){
            return AjaxResult.success(Collections.emptyList());
        }

        return AjaxResult.success(serviceCapabilities);
    }
}
