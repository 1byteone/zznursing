package com.zzyl.nursing.controller;

import java.util.List;
import java.util.concurrent.TimeUnit;
import javax.servlet.http.HttpServletResponse;

import com.zzyl.common.core.domain.R;
import com.zzyl.common.utils.PDFUtil;
import com.zzyl.common.utils.StringUtils;
import com.zzyl.oss.AliyunOSSOperator;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.zzyl.common.annotation.Log;
import com.zzyl.common.core.controller.BaseController;
import com.zzyl.common.core.domain.AjaxResult;
import com.zzyl.common.enums.BusinessType;
import com.zzyl.nursing.domain.HealthAssessment;
import com.zzyl.nursing.service.IHealthAssessmentService;
import com.zzyl.common.utils.poi.ExcelUtil;
import com.zzyl.common.core.page.TableDataInfo;
import org.springframework.web.multipart.MultipartFile;

/**
 * 健康评估Controller
 * 
 * @author alexis
 * @date 2026-03-21
 */
@Api("健康评估管理")
@RestController
@RequestMapping("/nursing/healthAssessment")
@Slf4j
public class HealthAssessmentController extends BaseController
{
    @Autowired
    private IHealthAssessmentService healthAssessmentService;

    @Autowired
    private AliyunOSSOperator aliyunOSSOperator;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    /**
     * 通用上传请求（单个）
     */
    @ApiOperation("上传体检报告")
    @PostMapping("/upload")
    public AjaxResult uploadFile(@RequestPart("file") MultipartFile file,
                                 @RequestPart(value = "idCard")  String idCardNo) {
        // 打印日志确认是否接收到
        System.out.println("接收到的身份证号: " + idCardNo);
        try {
            // 上传到OSS
            String url = aliyunOSSOperator.upload(file.getBytes(), file.getOriginalFilename());

            AjaxResult ajax = AjaxResult.success();
            ajax.put("url", url);
            ajax.put("fileName", url);
            // ajax.put("newFileName", url.substring(url.lastIndexOf("/")));
            ajax.put("originalFilename", file.getOriginalFilename());
            // PDF文件内容读取为字符串
            String content = PDFUtil.pdfToString(file.getInputStream());
            // 临时存储到redis中
            redisTemplate.opsForHash(). put("healthReport", idCardNo, content);

            // 设置 24 小时过期时间，确保用户在一天内可以完成提交
            redisTemplate.expire("healthReport", 24, TimeUnit.HOURS);

            return ajax;
        } catch (IllegalArgumentException e) {
            return AjaxResult.error(e.getMessage());
        } catch (Exception e) {
            return AjaxResult.error(e.getMessage());
        }
    }

    /**
     * 查询健康评估列表
     */
    @ApiOperation("查询健康评估列表")
    @PreAuthorize("@ss.hasPermi('nursing:healthAssessment:list')")
    @GetMapping("/list")
    public TableDataInfo<List<HealthAssessment>> list(@ApiParam("查询条件对象") HealthAssessment healthAssessment)
    {
        startPage();
        List<HealthAssessment> list = healthAssessmentService.selectHealthAssessmentList(healthAssessment);
        return getDataTable(list);
    }

    /**
     * 导出健康评估列表
     */
    @ApiOperation("导出健康评估列表")
    @PreAuthorize("@ss.hasPermi('nursing:healthAssessment:export')")
    @Log(title = "健康评估", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(@ApiParam("导出的查询条件") HttpServletResponse response, HealthAssessment healthAssessment)
    {
        List<HealthAssessment> list = healthAssessmentService.selectHealthAssessmentList(healthAssessment);
        ExcelUtil<HealthAssessment> util = new ExcelUtil<HealthAssessment>(HealthAssessment.class);
        util.exportExcel(response, list, "健康评估数据");
    }

    /**
     * 获取健康评估详细信息
     */
    @ApiOperation("获取健康评估详细信息")
    @PreAuthorize("@ss.hasPermi('nursing:healthAssessment:query')")
    @GetMapping(value = "/{id}")
    public R<HealthAssessment> getInfo(@PathVariable("id") @ApiParam("健康评估ID") Long id)
    {
        return R.ok(healthAssessmentService.selectHealthAssessmentById(id));
    }

    /**
     * 新增健康评估
     */
    @ApiOperation("新增健康评估")
    @PreAuthorize("@ss.hasPermi('nursing:healthAssessment:add')")
    @Log(title = "健康评估", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody @ApiParam("新增的健康评估对象") HealthAssessment healthAssessment)
    {
        Long id = healthAssessmentService.insertHealthAssessment(healthAssessment);
        return success(id);
    }

    /**
     * 修改健康评估
     */
    @ApiOperation("修改健康评估")
    @PreAuthorize("@ss.hasPermi('nursing:healthAssessment:edit')")
    @Log(title = "健康评估", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody @ApiParam("修改的健康评估对象") HealthAssessment healthAssessment)
    {
        return toAjax(healthAssessmentService.updateHealthAssessment(healthAssessment));
    }

    /**
     * 删除健康评估
     */
    @ApiOperation("删除健康评估")
    @PreAuthorize("@ss.hasPermi('nursing:healthAssessment:remove')")
    @Log(title = "健康评估", businessType = BusinessType.DELETE)
	@DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable @ApiParam("要删除的健康评估ID") Long[] ids)
    {
        return toAjax(healthAssessmentService.deleteHealthAssessmentByIds(ids));
    }
}
