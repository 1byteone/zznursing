package com.zzyl.nursing.controller.member;

import com.zzyl.common.core.controller.BaseController;
import com.zzyl.common.core.domain.R;
import com.zzyl.common.core.page.TableDataInfo;
import com.zzyl.nursing.domain.NursingProject;
import com.zzyl.nursing.service.INursingProjectService;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 护理项目Controller
 *
 * @author yjs
 * @date 2026-03-24
 */
@RestController
@RequestMapping("/member/orders/project")
public class MemberOrderProjectController extends BaseController {

    @Autowired
    private INursingProjectService nursingProjectService;

    /**
     * 查询护理项目列表
     */
    @GetMapping("/page")
    public TableDataInfo<List<NursingProject>> list(@ApiParam("查询条件对象") NursingProject nursingProject)
    {
        startPage();
        List<NursingProject> list = nursingProjectService.selectNursingProjectList(nursingProject);
        return getDataTable(list);
    }

    /**
     * 获取护理项目详细信息
     */
    @GetMapping(value = "/{id}")
    public R<NursingProject> getInfo(@PathVariable("id")  Long id)
    {
        return R.ok(nursingProjectService.selectNursingProjectById(id));
    }

}
