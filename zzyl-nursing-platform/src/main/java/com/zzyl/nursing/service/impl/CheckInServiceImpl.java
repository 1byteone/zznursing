package com.zzyl.nursing.service.impl;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.ObjectUtils;
import com.zzyl.common.constant.ScheduleConstants;
import com.zzyl.common.exception.base.BaseException;
import com.zzyl.common.utils.CodeGenerator;
import com.zzyl.common.utils.bean.BeanUtils;
import com.zzyl.nursing.domain.*;
import com.zzyl.nursing.dto.CheckInApplyDto;
import com.zzyl.nursing.dto.CheckInElderDto;
import com.zzyl.nursing.mapper.*;
import com.zzyl.nursing.vo.CheckInConfigVo;
import com.zzyl.nursing.vo.CheckInDetailVo;
import com.zzyl.nursing.vo.CheckInElderVo;
import com.zzyl.nursing.vo.ElderFamilyVo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.zzyl.nursing.service.ICheckInService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

/**
 * 入住Service业务层处理
 * 
 * @author yjs
 * @date 2026-03-17
 */
@Service
public class CheckInServiceImpl extends ServiceImpl<CheckInMapper, CheckIn> implements ICheckInService
{
    @Autowired
    private CheckInMapper checkInMapper;

    @Autowired
    private ElderMapper elderMapper;

    @Autowired
    private BedMapper bedMapper;

    @Autowired
    private CheckInConfigMapper checkInConfigMapper;

    @Autowired
    private ContractMapper contractMapper;

    /**
     * 获取入住详情
     *
     * @param id
     * @return
     */
    @Override
    public CheckInDetailVo detail(Long id) {
        //查询入住信息
        CheckIn checkIn = selectCheckInById(id);
        CheckInDetailVo checkInDetailVo = new CheckInDetailVo();
        
        //查询老人信息
        CheckInElderVo checkInElderVo = new CheckInElderVo();
        Elder elder = elderMapper.selectElderById(checkIn.getElderId());
        if (ObjectUtils.isNotEmpty(elder)) {
            BeanUtils.copyProperties(elder, checkInElderVo);
            
            //获取 elder 的 birthday 通过计算得到 checkInElderVo 的 age，并设置给 checkInElderVo
            Integer age1 = calculateAgeFromBirthday(elder.getBirthday());
            Integer age2 = calculateAgeFromIdCard(elder.getIdCardNo());
            //TODO:校验身份证年龄与填入老人生日日期是否一致的问题
            age1 = age1.equals(age2)?age2:age1;
            checkInElderVo.setAge(age1);
            
            checkInDetailVo.setCheckInElderVo(checkInElderVo);
        }

        //查询合同信息
        Contract contract = contractMapper.selectContractByElderId(checkIn.getElderId());
        checkInDetailVo.setContract(contract);

        //查询入住配置信息
        CheckInConfig checkInConfig = checkInConfigMapper.selectCheckInConfigByCheckInId(checkIn.getId());
        CheckInConfigVo checkInConfigVo = new CheckInConfigVo();
        if (ObjectUtils.isNotEmpty(checkInConfig)) {
            BeanUtils.copyProperties(checkInConfig, checkInConfigVo);
        }
        if (ObjectUtils.isNotEmpty(elder)) {
            checkInConfigVo.setBedNumber(elder.getBedNumber());
        }
        checkInDetailVo.setCheckInConfigVo(checkInConfigVo);

        //转换家属列表
        //将 checkIn 对象中的 remark 字段字符串对象转换成 json 对象为 elderFamilyVoList
        if (ObjectUtils.isNotEmpty(checkIn.getRemark())) {
            List<ElderFamilyVo> elderFamilyVoList = JSON.parseArray(checkIn.getRemark(), ElderFamilyVo.class);
            checkInDetailVo.setElderFamilyVoList(elderFamilyVoList);
        }

        //整合数据返回

        return checkInDetailVo;
    }

    /**
     * 查询入住
     * 
     * @param id 入住主键
     * @return 入住
     */
    @Override
    public CheckIn selectCheckInById(Long id)
    {
        return getById(id);
    }

    /**
     * 查询入住列表
     * 
     * @param checkIn 入住
     * @return 入住
     */
    @Override
    public List<CheckIn> selectCheckInList(CheckIn checkIn)
    {
        return checkInMapper.selectCheckInList(checkIn);
    }

    /**
     * 新增入住
     * 
     * @param checkIn 入住
     * @return 结果
     */
    @Override
    public int insertCheckIn(CheckIn checkIn)
    {
        return save(checkIn) ? 1 : 0;
    }

    /**
     * 修改入住
     * 
     * @param checkIn 入住
     * @return 结果
     */
    @Override
    public int updateCheckIn(CheckIn checkIn)
    {
        return updateById(checkIn) ? 1 : 0;
    }

    /**
     * 批量删除入住
     * 
     * @param ids 需要删除的入住主键
     * @return 结果
     */
    @Override
    public int deleteCheckInByIds(Long[] ids)
    {
        return removeByIds(Arrays.asList(ids)) ? 1 : 0;
    }

    /**
     * 删除入住信息
     * 
     * @param id 入住主键
     * @return 结果
     */
    @Override
    public int deleteCheckInById(Long id)
    {
        return removeById(id) ? 1 : 0;
    }

    /**
     * 申请入住
     *
     * @param dto
     */
    @Override
    public void apply(CheckInApplyDto dto) {
        //判断老人是否已经入住
        //通过身份证号查询老人
        LambdaQueryWrapper<Elder> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Elder::getIdCardNo,dto.getCheckInElderDto().getIdCardNo());
        queryWrapper.eq(Elder::getStatus,1);
        Elder elder = elderMapper.selectOne(queryWrapper);
        if(ObjectUtils.isNotEmpty( elder)){
            throw new BaseException("该老人已经入住");
        }

        //更新床位的状态 已入住
        Bed bed = bedMapper.selectById(dto.getCheckInConfigDto().getBedId());
        bed.setBedStatus(1);
        bedMapper.updateById(bed);

        //保存或更新老人数据
        elder = insertOrUpdate(bed, dto.getCheckInElderDto());

        //生成合同编号
        String contractNo = "HT" + CodeGenerator.generateContractNumber();

        //新增签约办理
        insertContract(contractNo,elder,dto);

        //新增入住数据
        CheckIn checkIn = insertCheckInfo(elder,dto);

        //新增入住配置信息
        insertCheckInConfig(checkIn.getId(),dto);


    }

    /**
     * 新增入住配置
     * @param checkInApplyDto
     */
    private void insertCheckInConfig(Long checkInId, CheckInApplyDto checkInApplyDto) {
        CheckInConfig checkInConfig = new CheckInConfig();
        BeanUtils.copyProperties(checkInApplyDto.getCheckInConfigDto(),checkInConfig);
        checkInConfig.setCheckInId(checkInId);
        checkInConfigMapper.insert(checkInConfig);
    }

    /**
     * 新增入住信息
     * @param elder
     * @param dto
     */
    private CheckIn insertCheckInfo(Elder elder, CheckInApplyDto dto) {
        CheckIn checkIn = new CheckIn();
        checkIn.setElderId(elder.getId());
        checkIn.setElderName(elder.getName());
        checkIn.setIdCardNo(elder.getIdCardNo());
        checkIn.setNursingLevelName(dto.getCheckInConfigDto().getNursingLevelName());
        checkIn.setStartDate(dto.getCheckInConfigDto().getStartDate());
        checkIn.setEndDate(dto.getCheckInConfigDto().getEndDate());
        checkIn.setBedNumber(elder.getBedNumber());
        checkIn.setRemark(JSON.toJSONString(dto.getElderFamilyDtoList()));
        checkIn.setStatus(0);
        checkInMapper.insert(checkIn);
        return checkIn;
    }


    /**
     * 新增合同
     * @param contractNo
     * @param elder
     * @param dto
     */
    private void insertContract(String contractNo, Elder elder, CheckInApplyDto dto) {

        Contract contract = new Contract();
        //属性拷贝
        BeanUtils.copyProperties(dto.getCheckInContractDto(),contract);
        contract.setContractNumber(contractNo);
        contract.setElderId(elder.getId());
        contract.setElderName(elder.getName());
        //状态、开始时间、结束时间
        //签约时间小于等于当前时间，合同生效中
        LocalDateTime checkInStartTime = dto.getCheckInConfigDto().getStartDate();
        LocalDateTime checkInEndTime = dto.getCheckInConfigDto().getEndDate();
        Integer status = checkInStartTime.isAfter(LocalDateTime.now()) ? 0 : 1;
        contract.setStatus(status);
        contract.setStartDate(checkInStartTime);
        contract.setEndDate(checkInEndTime);
        contractMapper.insert(contract);
    }

    /**
     * 新增或更新老人
     * @param bed
     * @param dto
     * @return
     */
    private Elder insertOrUpdate(Bed bed, CheckInElderDto dto) {

        //准备老人数据
        Elder elder = new Elder();
        //属性拷贝
        BeanUtils.copyProperties(dto,elder);
        elder.setBedNumber(bed.getBedNumber());
        elder.setBedId(bed.getId());
        elder.setStatus(1);
        //查询老人信息 （身份证号、状态不为1）
        LambdaQueryWrapper<Elder> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Elder::getIdCardNo,dto.getIdCardNo()).ne(Elder::getStatus,1);
        Elder elderDb = elderMapper.selectOne(queryWrapper);
        if(ObjectUtils.isNotEmpty(elderDb)){
            //修改
            elderMapper.updateById(elder);
        }else{
            //新增
            elderMapper.insert(elder);
        }
        return elder;
    }

    /**
     * 根据生日计算年龄
     * @param birthday 生日，格式：yyyy-MM-dd
     * @return 年龄
     */
    private Integer calculateAgeFromBirthday(String birthday) {
        if (birthday == null || birthday.trim().isEmpty()) {
            return null;
        }
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate birthDate = LocalDate.parse(birthday, formatter);
            Period period = Period.between(birthDate, LocalDate.now());
            return period.getYears();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 根据身份证号计算年龄
     * @param idCardNo 身份证号
     * @return 年龄
     */
    private Integer calculateAgeFromIdCard(String idCardNo) {
        if (idCardNo == null || idCardNo.length() < 15) {
            return null;
        }
        
        String birthdayStr;
        if (idCardNo.length() == 18) {
            // 18 位身份证，第 7-14 位是出生年月日
            birthdayStr = idCardNo.substring(6, 14);
        } else if (idCardNo.length() == 15) {
            // 15 位身份证，第 7-12 位是出生年月日（年份只有 2 位）
            birthdayStr = "19" + idCardNo.substring(6, 12);
        } else {
            return null;
        }
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
            LocalDate birthDate = LocalDate.parse(birthdayStr, formatter);
            Period period = Period.between(birthDate, LocalDate.now());
            return period.getYears();
        } catch (Exception e) {
            return null;
        }
    }

}
