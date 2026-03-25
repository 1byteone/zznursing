package com.zzyl.redis;

import com.zzyl.nursing.service.WechatService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class WechatServiceImplTest {

    @Autowired
    private WechatService wechatService;

    @Test
    public void testGetOpenid() {
        String openid = wechatService.getOpenid("0c1Ypl0w39sIK63fsf3w3chyPc3Ypl0D");
        System.out.println(openid);
    }

    @Test
    public void testGetPhone() {
        String phone = wechatService.getPhone("c2fe9c5a050fbe4df0a1d4fba13e1b4d017691e4bc57ba983047f30e5cf03ada");
        System.out.println(phone);
    }
}