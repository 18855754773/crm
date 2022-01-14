package com.bjpowernode.crm.web.listener;

import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.settings.service.impl.DicServiceImpl;
import com.bjpowernode.crm.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

public class SysInitListener implements ServletContextListener {

    /*
        该方法是用来监听上下文作用域对象的方法，当服务器启动，上下文作用域对象创建完毕后马上执行该方法

        event：该参数能够取得监听的对象
            监听的是什么对象，就可以取得什么对象

     */
    @Override
    public void contextInitialized(ServletContextEvent event) {

        System.out.println("服务器缓存处理数据字典开始");

        ServletContext application =  event.getServletContext();

        DicService ds = (DicService) ServiceFactory.getService(new DicServiceImpl());

        /*返回一个map */
        Map<String, List<DicValue>> map = ds.getAll();

        //将map对象进行拆解成 set集合 取到所有的 key
        Set<String> set = map.keySet();

        //遍历 key 来获取 value
        for (String key : set){

            application.setAttribute(key,map.get(key));

        }

        System.out.println("服务器缓存处理数据字典结束");

        //-------------------------------------------------------------------

        //解析properties文件
        ResourceBundle rb = ResourceBundle.getBundle("Stage2Possibility");

        Map<String,String> pMap = new HashMap<>();
        Enumeration<String> e = rb.getKeys();

        while (e.hasMoreElements()){

            //阶段
            String key = e.nextElement();

            //可能性
            String value = rb.getString(key);

            pMap.put(key,value);
        }

        //将pMap存储到服务器缓存中
        application.setAttribute("pMap",pMap);

    }

}
