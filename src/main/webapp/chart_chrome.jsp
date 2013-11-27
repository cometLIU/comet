<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript"  src="asserts/js/jquery-1.7.2.min.js"></script>
<script type="text/javascript">
	function putMessage(msg){
		var _lastMessage = $("#content").last();
		_lastMessage.after("<div>"+msg+"</div>");	
	}
</script>
<title>Insert title here</title>
<script type="text/javascript">
	var _userName = '<%=request.getParameter("userName")%>';
	//var server = 'http://10.28.160.9/comet/abc.cmt?name=' + _userName;
	var server = '<%=request.getContextPath()%>' +"/abc.cmt?name=" + _userName;
	var index = -1;
	var comet = {
		connection : false,
		iframediv : false,
		initialize : function() {
			$(".currentUser").val(_userName);
			if (navigator.appVersion.indexOf("MSIE") != -1) {
				//comet.connection = new ActiveXObject("htmlfile");
				//comet.connection.open();
				//comet.connection.write("__tag_18$36_");
				//comet.connection.write("__tag_19$36_document.domain = '"
				//		+ document.domain + "'");
				//comet.connection.write("__tag_20$36_");
				//comet.connection.close();
				//comet.iframediv = comet.connection.createElement("div");
				//comet.connection.appendChild(comet.iframediv);
				//comet.connection.parentWindow.comet = comet;
				//comet.iframediv.innerHTML = "__tag_25$41_</iframe>";
				var _iframe = '<iframe id="comet_iframe" src="http://localhost/comet/abc.cmt?name='+ _userName +'"'+ 
					'style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; visibility: hidden;"></iframe>';
				$(".container_12").after(_iframe);
			} else if (navigator.appVersion.indexOf("KHTML") != -1) {
				/**
				comet.connection = document.createElement('iframe');
				comet.connection.setAttribute('id', 'comet_iframe');
				comet.connection.setAttribute('src', server);
				with (comet.connection.style) {
					position = "absolute";
					left = top = "-100px";
					height = width = "1px";
					visibility = "hidden";
				}
				document.body.appendChild(comet.connection);
				**/
				//ajax 请求state 为3  
				comet.ajaxComet();
			} else {
				comet.ajaxComet();
			}
		},

		ajaxComet:function(){
			console.log("chrome");
			var xmlHttp = null;
			if(window.XMLHttpRequest){  
		        xmlHttp = new XMLHttpRequest();   
		    }else if(window.ActiveXObject){  
		        xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");  
		    }
		    
			xmlHttp.onreadystatechange = function(){
				if(xmlHttp.readyState==4 && xmlHttp.status==200){
					 console.log("xmlHttp.readyState:" + xmlHttp.readyState);
					 console.log("xmlHttp.status:" + xmlHttp.status);
					 console.log(xmlHttp.responseText); 
				}else if(xmlHttp.readyState==3 && xmlHttp.status==200){
					console.log("xmlHttp.readyState:" + xmlHttp.readyState);
					console.log("xmlHttp.status:" + xmlHttp.status);
					console.log(xmlHttp.responseText);
					//$(".ajax_hide").html(xmlHttp.responseText + "</body></html>");
					var _test = xmlHttp.responseText;
					if(index ==-1){
						var lastInput = _test.lastIndexOf("none>");
						index = lastInput + 5;
					}
					var _script =  _test.substring(index,_test.length);
					//console.log(_script);
					$(".ajax_hide").html(_script);
					index = _test.length;
				}else {
					//console.log("xmlHttp.readyState:" + xmlHttp.readyState);
					//console.log("xmlHttp.status:" + xmlHttp.status);
					//console.log(xmlHttp.responseText); 
				}
				  
			};
			var url = server;
			xmlHttp.open("get",url,true);  
			xmlHttp.send(null);
		},
		//添加用户  
		newUser : function(data) {
			var list = document.getElementById('userList');
			var li = document.createElement('li');
			li.setAttribute("id", "u1" + data);
			li.innerHTML = data;
			list.appendChild(li);

			var user = document.getElementById('user');
			var option = document.createElement('option');
			option.setAttribute("id", "u2" + data);
			option.innerHTML = data;
			user.appendChild(option);
		},

		//删除用户  
		deleteUser : function(data) {
			$('#u1' + data).remove();
			$('#u2' + data).remove();
		},

		//添加公共消息  
		newMessage : function(data) {
			/**
			var list = document.getElementById('messageList');
			var li = document.createElement('li');
			li.innerHTML = data;
			list.appendChild(li);
			**/
			var _html = '<li><span style="color: red; font-weight: bold; font-size: 19px;">' +
			data.currentUser + '：</span><br> <span style="padding-left: 50px;">'+data.message+'</span></li>';

			$("#messageList").append(_html);
			//滚动到底部
			$("#messageList").scrollTop(100000);
		},
		
		//欢迎信息
		welcomeMessage:function(data){
			var list = document.getElementById('messageList');
			var li = document.createElement('li');
			li.innerHTML = data;
			list.appendChild(li);
		},
		
		//添加私人消息  
		privateMessage : function(data) {
			/**
			var list = document.getElementById('privateMessage');
			var li = document.createElement('li');
			li.innerHTML = data;
			list.appendChild(li);
			**/
			
			var _html = '<li><span style="color: red; font-weight: bold; font-size: 19px;">' +
			data.currentUser + '：</span><br> <span style="padding-left: 50px;">'+data.message+'</span></li>';

			$("#privateMessage").append(_html);
			//滚动到底部
			$("#privateMessage").scrollTop(100000);
		},

		//退出  
		onUnload : function() {
			if (comet.connection) {
				comet.connection = false;
			}
		}
	}
	//comet end  

	if (window.addEventListener) {
		window.addEventListener("load", comet.initialize, false);
		window.addEventListener("unload", comet.onUnload, false);
	} else if (window.attachEvent) {
		window.attachEvent("onload", comet.initialize);
		window.attachEvent("onunload", comet.onUnload);
	}
</script>
</head>

<body>
<script type="text/javascript">
	function sendAll() {
		/**
		var list = document.getElementById('privateMessage');
		var li = document.createElement('li');
		li.innerHTML = "I said to " + $("#user").val() + ": "
				+ $("#message").val();
		list.appendChild(li);
		**/
		var _chartType = $(".chartType").val();
		if(_chartType != "all" || !_chartType){
			var _html = '<li><span style="color: red; font-weight: bold; font-size: 19px;">' +
			$(".currentUser").val()  + '：</span><br> <span style="padding-left: 50px;">'+$("#message").val()+'</span></li>';
			$("#privateMessage").append(_html);
			//滚动到底部
			$("#privateMessage").scrollTop(100000);
		}
		
		$.ajax( {
			type : "POST",
			url : "MessageServlet.msg",
			data : "message=" + $("#message").val() + "&user="
					+ $("#user").val() + "&currentUser=" +$(".currentUser").val() 
					+ "&chartType="+$(".chartType").val()
					+ "&from=__tag_122$79_"
		});
	}

	$(function(){
		$("#user").change(function(){
			var _chartType = $(this).children('option:selected').val();
			$(".chartType").val(_chartType);
		});
	});
</script>
	<form>
		<input type="hidden" class="currentUser"></input>
		<input type="hidden" class="chartType" value="all"></input>
	</form>
	<div class="container_12">
		<div class="grid_10">
			<div>公共聊天</div>
			<div id="messageList" style="height: 250px; overflow: scroll; border: solid 1px black;">
			</div>
			<br />
			<!-- -->
			<div>个人聊天</div>
			<div id="privateMessage" style="height: 150px; overflow: scroll; border: solid 1px black;">
			</div>
			<br />
			 
			<div>
				<select id="user" style="width: 100px; overflow: scroll;">
					<option value="all" selected="selected">All</option>
				</select>
				 <input type="text" id="message" size="40"></input>
				  <input type="button"	value="发言" onclick=	sendAll();>
		   </div>
		</div>
		
		<div class="grid_2">
			<h3>用户列表</h3>
			<ol id="userList">
			</ol>
		</div>
		
		<div class="ajax_hide" style="display:none">
		
		</div>
	</div>
</body>
</html>