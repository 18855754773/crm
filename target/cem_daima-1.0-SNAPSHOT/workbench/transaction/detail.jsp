<%@ page import="java.util.List" %>
<%@ page import="com.bjpowernode.crm.settings.domain.DicValue" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.bjpowernode.crm.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
	String basePath = request.getScheme() + "://"+request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";

	//准备字典类型为stage的字典类型值
	List<DicValue> dvList = (List<DicValue>) application.getAttribute("stageList");

	//准备阶段和可能性直接的关系
	Map<String,String> pMap = (Map<String, String>) application.getAttribute("pMap");

	//根据pMap准备pMap中的key合集
	Set<String> set = pMap.keySet();

	//准备前面阶段和后面丢失阶段的分界点下标
	int point = 0;
	for (int i = 0; i < dvList.size(); i++){

		//取得每个阶段的字典值
		DicValue dv = dvList.get(i);

		//从dv中取得value
		String stage = dv.getValue();

		//根据stage获取possibility
		String possibility = pMap.get(stage);//可能性

		//根据可能性来找出分界点的下标
		if ("0".equals(possibility)){

			point = i;
			break;

		}

	}

%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />

<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});
		
		
		//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'bottom',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                });

		//在页面加载完毕后展现交易列表
		showHistoryList();

	});
	
	function showHistoryList() {

		$.ajax({
			url:"workbench/transaction/getHistoryListByTranId.do",
			data:{
				"tranId":"${t.id}"
			},
			type: "get",
			dataType: "json",
			success:function (data) {

				var html = "";

				$.each(data,function (i,n) {

					html += '<tr>';
					html += '<td>'+ n.stage +'</td>';
					html += '<td>'+ n.money +'</td>';
					html += '<td>'+ n.possibility +'</td>';
					html += '<td>'+ n.expectedDate +'</td>';
					html += '<td>'+ n.createTime +'</td>';
					html += '<td>'+ n.createBy +'</td>';
					html += '</tr>';

				})

				$("#tranHistoryBody").html(html);
			}
		})

	}

	//-------------------改变交易阶段的方法--------------------------
	function changeStage(stage,i) {


		$.ajax({
			url:"workbench/transaction/changeStage.do",
			data:{
				"id":"${t.id}",
				"stage" : stage,
				"money":"${t.money}", //生成交易历史用
				"expectedDate":"${t.expectedDate}" //生成交易历史用
			},
			type: "post",
			dataType: "json",
			success:function (data) {

				if (data.success){

					//改变成功 要在详细信息页面上刷新 阶段 可能性 修改人 修改时间
					$("#stage").html(data.t.stage);
					$("#possibility").html(data.t.possibility);
					$("#editBy").html(data.t.editBy);
					$("#editTime").html(data.t.editTime);

					//改变成功之后将所有的图标进行判断
					changeIcon(stage,i);

					showHistoryList();

				}else {

					alert("改变阶段失败")

				}

			}
		})

	}
	function changeIcon(stage,index1) {

		//当前阶段
		var currentStage = stage;
		//当前阶段下表
		var index = index1;
		//前面正常阶段和后面丢失阶段的临界点啊
		var point = "<%=point%>";

		//如果当前阶段的下表大于临界点下表  就一定是后俩阶段 前面七个阶段都是黑圈 后俩一个是红叉一个是黑叉
		if (index >= point){

			//遍历前七个
			for (var i = 0; i < point; i++){
				//------------------黑圈----------------
				//先把原来的样式去除
				$("#"+i).removeClass();
				//添加新样式
				$("#"+i).addClass("glyphicon glyphicon-record mystage");
				//给新样式加颜色
				$("#"+i).css("color","#000000")

			}
			//遍历后两个
			for (var i = point; i < <%=dvList.size()%>; i++){

				//如果是当前阶段
				if (i==index){

					//----------红叉-------------
					//先把原来的样式去除
					$("#"+i).removeClass();
					//添加新样式
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					//给新样式加颜色
					$("#"+i).css("color","#FF0000")

				//如果不是当前阶段
				}else {

					//-----------------------黑叉----------------
					//先把原来的样式去除
					$("#"+i).removeClass();
					//添加新样式
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					//给新样式加颜色
					$("#"+i).css("color","#000000")

				}

			}

		//如果当前阶段小于临界点 或者等于临界点 就一定是前七个阶段 后面俩叉一定是黑色
		}else {

			//遍历前七个
			for (var i = 0; i < point; i++){

				//如果是当前阶段
				if (i==index){

					//------------绿标-----------
					//先把原来的样式去除
					$("#"+i).removeClass();
					//添加新样式
					$("#"+i).addClass("glyphicon glyphicon-map-marker mystage");
					//给新样式加颜色
					$("#"+i).css("color","#90F790")

				//如果小于当前阶段
				}else if (i<index){

					//--------------------绿圈--------
					//先把原来的样式去除
					$("#"+i).removeClass();
					//添加新样式
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					//给新样式加颜色
					$("#"+i).css("color","#90F790")


					//如果大于当前阶段
				}else {

					//--------------------黑圈-----------
					//先把原来的样式去除
					$("#"+i).removeClass();
					//添加新样式
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					//给新样式加颜色
					$("#"+i).css("color","#000000")

				}


			}

			//遍历后两个
			for (var i = point; i < <%=dvList.size()%>; i++){

				//----------------黑叉---------------
				//先把原来的样式去除
				$("#"+i).removeClass();
				//添加新样式
				$("#"+i).addClass("glyphicon glyphicon-remove mystage");
				//给新样式加颜色
				$("#"+i).css("color","#000000")

			}

		}

	}
	
</script>

</head>
<body>
	
	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${t.customerId}-${t.name} <small>￥${t.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='edit.html';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>

	<!-- 阶段状态 -->
	<div style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

		 <%

			 //准备当前阶段
			 Tran t = (Tran) request.getAttribute("t");
			 String currentStage = t.getStage();
			 //准备当前阶段的可能性
			 String currentPossibility = pMap.get(currentStage);

			 //判断当前阶段
			 //如果当前阶段可能性为0  前面七个 一定是 黑圈  后面俩叉 是一个红色 一个黑色
			 if ("0".equals(currentPossibility)){

				for (int i = 0; i < dvList.size();i++){

					//遍历出每一个阶段 根据每一个遍历出来的阶段来获取可能性
					DicValue dv = dvList.get(i);
					String listStage = dv.getValue();
					String listPossibility = pMap.get(listStage);

					//如果遍历出来的可能性为零  说明是 后两个
					if ("0".equals(listPossibility)){

						//如果是当前阶段 就是红叉
						if (listStage.equals(currentStage)){

							//---------------红叉----------------
			%>

				<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
					  class="glyphicon glyphicon-remove mystage"
					  data-toggle="popover" data-placement="bottom"
					  data-content="<%=dv.getText()%>" style="color: #FF0000;"></span>
				-----------

			<%
						//如果不是当前阶段 就是黑叉
						}else {

							//----------------黑叉---------------
			%>

				<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
					  class="glyphicon glyphicon-remove mystage"
					  data-toggle="popover" data-placement="bottom"
						  data-content="<%=dv.getText()%>" style="color: #000000;"></span>
				-----------

			<%

							}

							//如果遍历出来的可能不为0 说明是前七个
						}else {

							//---------黑圈--------------------
			%>

				<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
					  class="glyphicon glyphicon-record mystage"
					  data-toggle="popover" data-placement="bottom"
					  data-content="<%=dv.getText()%>" style="color: #000000;"></span>
				-----------

			<%

					}

				}

				//如果当前阶段不为0 后面俩叉一定是黑色 前面七个阶段可能是 绿钩 或者 绿标 或者黑圈
			 }else {
				//准备当前阶段的下标
				 int index = 0;
				 for (int i = 0; i < dvList.size(); i++){
					DicValue dv = dvList.get(i);
					String stage = dv.getValue();
					//如果遍历出来的是当前阶段 就找到了当前阶段的下标
					if (stage.equals(currentStage)){
						index = i;
						break;
					}
				 }

				 for (int i = 0; i < dvList.size();i++) {

					 //遍历出每一个阶段 根据每一个遍历出来的阶段来获取可能性
					 DicValue dv = dvList.get(i);
					 String listStage = dv.getValue();
					 String listPossibility = pMap.get(listStage);
					 //如果遍历出来的阶段 是0 一定是后两个 都是黑叉
					 if("0".equals(listPossibility)){
						//------------黑叉-------------------

			%>

				<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
					  class="glyphicon glyphicon-remove mystage"
					  data-toggle="popover" data-placement="bottom"
					  data-content="<%=dv.getText()%>" style="color: #000000;"></span>
				-----------

			<%


		//如果不是零 就是前面七个阶段
					 }else {

						//小于当前阶段
						if (i < index){
							//----绿圈----------------------
			%>

				<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
					  class="glyphicon glyphicon-record mystage"
					  data-toggle="popover" data-placement="bottom"
					  data-content="<%=dv.getText()%>" style="color: #90F790;"></span>
				-----------

			<%



		//等于当前阶段
						}else if (i == index){
							//-----绿标----------------------------

			%>

				<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
					  class="glyphicon glyphicon-map-marker mystage"
					  data-toggle="popover" data-placement="bottom"
					  data-content="<%=dv.getText()%>" style="color: #90F790;"></span>
				-----------

			<%

						//大于当前阶段
						}else {
							//-------黑圈--------------------

			%>

				<span id="<%=i%>" onclick="changeStage('<%=listStage%>','<%=i%>')"
					  class="glyphicon glyphicon-record mystage"
					  data-toggle="popover" data-placement="bottom"
					  data-content="<%=dv.getText()%>" style="color: #000000;"></span>
				-----------

			<%

						}

					 }

				 }


			 }

		 %>

<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="资质审查" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="需求分析" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="价值建议" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="确定决策者" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="提案/报价" style="color: #90F790;"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="谈判/复审"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="成交"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="丢失的线索"></span>
		-----------
		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="因竞争丢失关闭"></span>
		-------------%>
		<span class="closingDate">${t.expectedDate}</span>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${t.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.customerId}-${t.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${t.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${t.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">${t.possibility}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${t.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${t.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${t.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${t.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${t.editBy}&nbsp;&nbsp;</b><small id="editTime" style="font-size: 10px; color: gray;">${t.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${t.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${t.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${t.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>

	<!-- 备注 -->
	<div style="position: relative; top: 100px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<!-- 备注2 -->
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="tranHistoryBody">
						<%--<tr>
							<td>资质审查</td>
							<td>5,000</td>
							<td>10</td>
							<td>2017-02-07</td>
							<td>2016-10-10 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>需求分析</td>
							<td>5,000</td>
							<td>20</td>
							<td>2017-02-07</td>
							<td>2016-10-20 10:10:10</td>
							<td>zhangsan</td>
						</tr>
						<tr>
							<td>谈判/复审</td>
							<td>5,000</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>2017-02-09 10:10:10</td>
							<td>zhangsan</td>
						</tr>--%>
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>