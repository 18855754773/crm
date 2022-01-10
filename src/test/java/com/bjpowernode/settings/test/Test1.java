package com.bjpowernode.settings.test;

import com.bjpowernode.crm.utils.DateTimeUtil;

public class Test1 {

    public static void main(String[] args) {

        String exp = "2018-10-10 10:10:10";
        String dang = DateTimeUtil.getSysTime();
        int jieguo = exp.compareTo(dang);
        System.out.println(jieguo);

    }

}
