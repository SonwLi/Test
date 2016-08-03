<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<%@ page language="java" %>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.xietong.software.jn.*,com.xietong.software.jnpicc.db.*"%>
<%@ page import="com.xietong.software.util.*,com.xietong.software.common.*"%>
<%@ page import="org.apache.commons.logging.*"%>
<%@ page import="java.io.*,java.util.*"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
	<style type="text/css">
		body, html{width: 100%;height: 100%;margin:0;font-family:"微软雅黑";font-size:14px;}
		#container { width:100%; padding:0; margin:0 auto; height:100%;}
		#leftDiv { 
			width:20%;
			float:left; 
			text-align:center; 
			line-height:normal ;  
			vertical-align: left; 
			height:100%; 
			display:block; 
			background-color:#ccc; 
			color:#333;
			}
		#rightDiv { width:80%; float:right; text-align:center; line-height:600px; height:100%; display:block; background-color:#c00; color:#fff;}
	</style>
	<script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=4dM8thrVGdkZif6vCpxq1ZXZqkzYPHsp"></script>
	<script src="js/jquery-1.7.2.min.js"></script>
	<title>救援商位置标注</title>
</head>
<body>
	<div id="container"> 
    	<div id="leftDiv">
    		<h3>救援商名称:</h3>
            <table width="95%" border="0" cellspacing="5" cellpadding="0">
               <tr>
                   <td>救援商位置坐标:</td>
                   <td><input type="text" id="dispot" size="20" value="" style="width:150px;" /></td>
               </tr>
               <tr>
                   <td>位置查找:</td>
                   <td><input type="text" id="suggestId" size="20" value="" style="width:150px;" /></td>
               </tr>
               
                <tr>
                   <td ><input type="button"value="标记" onclick="javascript:dispot()"></input></td>
                    <td ><input type="button"value="返回" onclick="javascript:goBack();"></input></td>
               </tr>
            </table>   
    	</div> 
		<div id="searchResultPanel" style="border:1px solid #C0C0C0;width:250px;height:auto; display:none;"></div>
    	<div id="rightDiv">
    	</div> 
	</div> 
</body>
<script type="text/javascript">
	function goBack(){
		/* var str=document.getElementById('dispot').value;
		var pointStr=str.split(',');
		window.opener.getElementById("Longitudes").value=pointStr[0];
		window.opener.getElementById("Latitudes").value=pointStr[1]; */
		window.history.go(-1);
	}
	// 百度地图API功能
	function G(id) {
		return document.getElementById(id);
	}

	var map = new BMap.Map("rightDiv");
	map.enableScrollWheelZoom(true); 
	map.setDefaultCursor("url('bird.cur')"); 
	map.addEventListener("click",function(e){
		document.getElementById('dispot').value=e.point.lng + "," + e.point.lat;
	});// 初始化地图,设置城市和地图级别。
	if(document.getElementById('dispot').value=null){
		var str=document.getElementById('dispot').value;
		var pointStr=str.split(',');
		var point = new BMap.Point(pointStr[0], pointStr[1]);
		map.centerAndZoom(point, 15);
		var marker = new BMap.Marker(point);  // 创建标注
		map.addOverlay(marker);
		var infoWindow =new BMap.InfoWindow("<div style='line-height:1.8em;font-size:12px;'><b>名称:</b></br></div>", opts1); 
		marker.addEventListener("click",function(e){
				this.openInfoWindow(infoWindow);
			}
		);
	}else{
		map.centerAndZoom("济南",15);  
	}
	var ac = new BMap.Autocomplete(    //建立一个自动完成的对象
		{"input" : "suggestId"
		,"location" : map
	});

	ac.addEventListener("onhighlight", function(e) {  //鼠标放在下拉列表上的事件
	var str = "";
		var _value = e.fromitem.value;
		var value = "";
		if (e.fromitem.index > -1) {
			value = _value.province +  _value.city +  _value.district +  _value.street +  _value.business;
		}    
		str = "FromItem<br />index = " + e.fromitem.index + "<br />value = " + value;
		
		value = "";
		if (e.toitem.index > -1) {
			_value = e.toitem.value;
			value = _value.province +  _value.city +  _value.district +  _value.street +  _value.business;
		}    
		str += "<br />ToItem<br />index = " + e.toitem.index + "<br />value = " + value;
		G("searchResultPanel").innerHTML = str;
	});

	var myValue;
	ac.addEventListener("onconfirm", function(e) {    //鼠标点击下拉列表后的事件
	var _value = e.item.value;
		myValue = _value.province +  _value.city +  _value.district +  _value.street +  _value.business;
		G("searchResultPanel").innerHTML ="onconfirm<br />index = " + e.item.index + "<br />myValue = " + myValue;
		setPlace();
	});

	function setPlace(){
		//map.clearOverlays();    //清除地图上所有覆盖物
		function myFun(){
			var pp = local.getResults().getPoi(0).point;    //获取第一个智能搜索的结果
			map.centerAndZoom(pp, 18);
			map.addOverlay(new BMap.Marker(pp));    //添加标注
		}
		var local = new BMap.LocalSearch(map, { //智能搜索
		  onSearchComplete: myFun
		});
		local.search(myValue);
	}
	function openInfo(content,e){
		var p = e.target;
		var point = new BMap.Point(p.getPosition().lng, p.getPosition().lat);
		var infoWindow = new BMap.InfoWindow(content,opts);  // 创建信息窗口对象 
		map.openInfoWindow(infoWindow,point); //开启信息窗口
	}
	var opts1 = {title : '<span style="font-size:14px;color:#0A8021">救援商信息</span>'};
	function addClickHandler(content,marker){
		marker.addEventListener("click",function(e){
			openInfo(content,e)}
		);
	}
	function dispot(){
		var str=document.getElementById('dispot').value;
		var pointStr=str.split(',');
		var point = new BMap.Point(pointStr[0], pointStr[1]);
		map.centerAndZoom(point, 15);
		var marker = new BMap.Marker(point);  // 创建标注
		map.addOverlay(marker);
		var infoWindow =new BMap.InfoWindow("<div style='line-height:1.8em;font-size:12px;'></div>", opts1); 
		marker.addEventListener("click",function(e){
				this.openInfoWindow(infoWindow);
			}
		);
		$.ajax({
			url: 'Rec_T_RecServerInfoAction.jsp?cmd=setPoint&serverId=12&point='+str,
			type: 'GET',
			dataType: 'text',
			timeout: 5000,
			error: function(){
				alert('error');
			},
			success: function(text){
				text=text.trim();
				if(text=='1')alert("标记成功");
				else alert("标记失败");
			}
		});  
		
	}
</script>	
</html>
