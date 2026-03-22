package com.nursing.test;

import com.zzyl.common.utils.PDFUtil;

import java.io.FileInputStream;
import java.io.FileNotFoundException;

public class PDFUtilTest {

    public static void main(String[] args) throws FileNotFoundException {

        FileInputStream fileInputStream = new FileInputStream ("D:\\BaiduNetdiskDownload\\中州养老-资料\\09. 智能评估-集成AI大模型\\资料\\体检报告样例\\体检报告-刘爱国-男-69岁.pdf");
        String result = PDFUtil.pdfToString(fileInputStream);
        System.out.println(result);
    }
}