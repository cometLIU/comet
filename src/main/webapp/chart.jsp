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
	var server = 'http://localhost/comet/abc.cmt?name=' + _userName;
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

			} else {
				comet.connection = document.createElement('iframe');
				comet.connection.setAttribute('id', 'comet_iframe');
				
				with (comet.connection.style) {
					left = top = "-100px";
					height = width = "1px";
					visibility = "hidden";
					display = 'none';
				}
				comet.iframediv = document.createElement('iframe');
				comet.iframediv.setAttribute('src', server);
				comet.connection.appendChild(comet.iframediv);
				document.body.appendChild(comet.connection);
			}
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
			var list = document.getElementById('messageList');
			var li = document.createElement('li');
			li.innerHTML = data;
			list.appendChild(li);
			
		},

		//添加私人消息  
		privateMessage : function(data) {
			var list = document.getElementById('privateMessage');
			var li = document.createElement('li');
			li.innerHTML = data;

			list.appendChild(li);
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
		var list = document.getElementById('privateMessage');
		var li = document.createElement('li');
		li.innerHTML = "I said to " + $("#user").val() + ": "
				+ $("#message").val();
		list.appendChild(li);

		$.ajax( {
			type : "POST",
			url : "MessageServlet.msg",
			data : "message=" + $("#message").val() + "&user="
					+ $("#user").val() + "&currentUser" + $(".currentUser").val()+ "&from=__tag_122$79_"
		});
	}
</script>
	<form >
		<input type="hidden" class="currentUser">
	</form>
	<div class="container_12">
		<div class="grid_10">
			<div>公共聊天</div>
			<div id="messageList" style="height: 250px; overflow: scroll; border: solid 1px black;">
			</div>
			<br />
			
			<div>个人聊天</div>
			<div id="privateMessage" style="height: 150px; overflow: scroll; border: solid 1px black;">
			</div>
			<br />
			
			<div>
				<select id="user" style="width: 100px; overflow: scroll;">
					<option value="all">All</option>
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
	</div>
</body>
</html>