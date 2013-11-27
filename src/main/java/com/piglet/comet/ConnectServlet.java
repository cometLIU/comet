package com.piglet.comet;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.catalina.CometEvent;
import org.apache.catalina.CometProcessor;

public class ConnectServlet extends HttpServlet implements CometProcessor{
	 private static final long serialVersionUID = -3667180332947986301L;  
	  
	    // <用户,长连接>  
	    protected Map<String, HttpServletResponse> connections = new HashMap<String, HttpServletResponse>();  
	  
	    // 消息推送线程  
	    protected static MessageSender messageSender = null;  
	  
	    public void init() throws ServletException {  
	        // 启动消息推送线程  
	    	messageSender = MessageSender.getMessageSenderInstance();
	        messageSender.setConnections(connections);
	        Thread messageSenderThread = new Thread(messageSender, "MessageSender["
	                + getServletContext().getContext("") + "]");  
	        messageSenderThread.setDaemon(true);  
	        messageSenderThread.start();  
	    }  
	  
	    public void destroy() {  
	        connections.clear();  
	        messageSender.stop();  
	        messageSender = null;  
	    }  
	  
	    public void event(CometEvent event) throws IOException, ServletException {  
	        HttpServletRequest request = event.getHttpServletRequest();  
	        HttpServletResponse response = event.getHttpServletResponse();  
	        
	        // 昵称  
	        String name = request.getParameter("name");  
	        if (name == null) {  
	            return;  
	        }  
	        if (event.getEventType() == CometEvent.EventType.BEGIN) {  
	            // Http连接空闲超时  
	            event.setTimeout(Integer.MAX_VALUE);  
	            log("Begin for session: " + request.getSession(true).getId());  
	            response.setCharacterEncoding("UTF-8");
	            // 创建Comet Iframe  
	            PrintWriter writer = response.getWriter();  
	            writer  
	                    .println("<!doctype html public \"-//w3c//dtd html 4.0 transitional//en\">");  
	            writer  
	                    .println("<html><head><script type=\"text/javascript\">var comet = window.parent.comet;</script></head><body>");  
	            writer.println("<script type=\"text/javascript\">");  
	            writer.println("var comet = window.parent.comet;");  
	            writer.println("</script>");  
	            writer.flush();  
	  
	            // for chrome  
	            //if (request.getHeader("User-Agent").contains("KHTML") || request.getHeader("User-Agent").contains("Mozilla")) {  
	                for (int i = 0; i < 100; i++) {  
	                    writer.print("<input type=hidden name=none value=none>");  
	                }  
	                writer.flush();  
	            //}  
	  
	            // 欢迎信息  
	            writer.print("<script type=\"text/javascript\">");  
	            writer.println("comet.welcomeMessage('Hello " + name + ", Welcome!');");  
	            writer.print("</script>");  
	            writer.flush();  
	  
	            // 通知其他用户有新用户登陆  
	            if (!connections.containsKey(name)) {  
	                messageSender.login(name);  
	            }  
	  
	            // 推送已经登陆的用户信息  
	            for (String user : connections.keySet()) {  
	                if (!user.equals(name)) {  
	                    writer.print("<script type=\"text/javascript\">");  
	                    writer.println("comet.newUser('" + user + "');");  
	                    writer.print("</script>");  
	                }  
	            }  
	            writer.flush();  
	  
	            synchronized (connections) {  
	                connections.put(name, response);  
	            }  
	        } else if (event.getEventType() == CometEvent.EventType.ERROR) {  
	            log("Error for session: " + request.getSession(true).getId());  
	            synchronized (connections) {  
	                connections.remove(name);  
	            }  
	            event.close();  
	        } else if (event.getEventType() == CometEvent.EventType.END) {  
	            log("End for session: " + request.getSession(true).getId());  
	            messageSender.logout(name);  
	            synchronized (connections) {  
	                connections.remove(name);  
	            }  
	            PrintWriter writer = response.getWriter();  
	            writer.println("</body></html>");  
	            event.close();  
	        } else if (event.getEventType() == CometEvent.EventType.READ) {  
	            InputStream is = request.getInputStream();  
	            byte[] buf = new byte[512];  
	            do {  
	                int n = is.read(buf); // can throw an IOException  
	                if (n > 0) {  
	                    log("Read " + n + " bytes: " + new String(buf, 0, n)  
	                            + " for session: "  
	                            + request.getSession(true).getId());  
	                } else if (n < 0) {  
	                    return;  
	                }  
	            } while (is.available() > 0);  
	        }  
	    }  
	  
	    // 发送消息给所有人  
	    public static void send(String message) {  
	        messageSender.send("*", message);  
	    }  
	  
	    // 向某个连接发送消息  
	    public static void send(String name, String message) {  
	        messageSender.send(name, message);  
	    }  
	  
	    
}
