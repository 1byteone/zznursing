package com.zzyl.nursing.task;

import com.zzyl.nursing.service.IContractService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class ContractTask {

    @Autowired
    private IContractService contractService;

    public void updateContractStatusTask(){
        contractService.updateContractStatus();
        log.info("定时更新合同状态成功！");
    }

}
