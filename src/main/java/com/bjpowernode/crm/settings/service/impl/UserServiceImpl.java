package com.bjpowernode.crm.settings.service.impl;

import com.bjpowernode.crm.exception.loginException;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import org.apache.ibatis.session.SqlSession;

import java.sql.SQLOutput;
import java.util.HashMap;
import java.util.Map;

public class UserServiceImpl implements UserService {

    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    @Override
    public User login(String loginAct, String loginPwd, String ip) throws loginException {

        Map<String,String> map = new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);


        UserDao dao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
        User user = dao.login(map);

        if (user == null){

            throw new loginException("账号密码错误");

        }

        //如果程序执行到这里说明这里的账号密码是正确的，需要继续往下验证其他三项信息

        //验证失效时间
        String expireTime = user.getExpireTime();
        String currentTime = DateTimeUtil.getSysTime();

        //compareTo 用来比较字符串大小 返回int类型  如果 返回是正数表示 EditTime 比currentTime大
        //否则反之 0 表示相等
        if (expireTime.compareTo(currentTime) < 0){

            throw new loginException("账号已失效");

        }

        //判断 账号的状态 是否锁定
        if ("0".equals(user.getLockState())){

            throw new loginException("账号已锁定");

        }

        //判断账户的ip地址是否包含
        if (!user.getAllowIps().contains(ip)){

            throw new loginException("ip地址受限");

        }

        return user;
    }
}
