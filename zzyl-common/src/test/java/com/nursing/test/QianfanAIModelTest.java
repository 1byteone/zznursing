package com.nursing.test;

import com.openai.client.OpenAIClient;
import com.openai.client.okhttp.OpenAIOkHttpClient;
import com.openai.models.ResponseFormatJsonObject;
import com.openai.models.chat.completions.ChatCompletion;
import com.openai.models.chat.completions.ChatCompletionCreateParams;

public class QianfanAIModelTest {
    public static void main(String[] args) {
        OpenAIClient client = OpenAIOkHttpClient.builder()
                .apiKey("bce-v3/ALTAK-e4khnEVx1fiW9FApX4PN3/b974bc00317dceef49c2cb814d66b5952e3c6b6f") //将your_APIKey替换为真实值，如何获取API Key请查看https://cloud.baidu.com/doc/WENXINWORKSHOP/s/Um2wxbaps#步骤二-获取api-key
                .baseUrl("https://qianfan.baidubce.com/v2/") //千帆ModelBuilder平台地址
                .build();

        ChatCompletionCreateParams params = ChatCompletionCreateParams.builder()
                .addUserMessage("你好") // 对话messages信息
                .model("deepseek-r1") // 模型对应的model值，请查看支持的模型列表：https://cloud.baidu.com/doc/WENXINWORKSHOP/s/wm7ltcvgc
                .responseFormat(ChatCompletionCreateParams.ResponseFormat.ofJsonObject(ResponseFormatJsonObject.builder().build()))
                .build();

        ChatCompletion chatCompletion = client.chat().completions().create(params);
        System.out.println(chatCompletion.choices().get(0).message().content().orElseGet(() -> ""));
    }
}