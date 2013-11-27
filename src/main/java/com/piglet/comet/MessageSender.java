package com.piglet.comet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;


public class MessageSender implements Runnable {  
	  
    protected boolean running = true;  
    protected Map<String, Object> messages = new HashMap<String, Object>();  
    // <用户,长连接>  
    private Map<String, HttpServletResponse> connections = null;
    
    private static MessageSender messageSender = new MessageSender();
   
    public MessageSender() {  

    }  

    public void stop() {  
        running = false;  
    }  

    // 新用户登陆  
    public void login(String name) {  
        synchronized (messages) {  
            messages.put("Login", name);  
            messages.notify();  
        }  
    }  

    // 用户下线  
    public void logout(String name) {  
        synchronized (messages) {  
            messages.put("Logout", name);  
            messages.notify();  
        }  
    }  

    // 发送消息  
    public void send(String user, String message) {  
        synchronized (messages) {  
            messages.put(user, message);  
            messages.notify();  
        }  
    }  

    public void run() {  
        while (running) {  
            if (messages.size() == 0) {  
                try {  
                    synchronized (messages) {  
                        messages.wait();  
                    }  
                } catch (InterruptedException e) {  
                    // Ignore  
                }  
            }  

            synchronized (connections) {  
                synchronized (messages) {  
                    // 推送消息队列中的消息  
                    for (Entry<String, Object> message : messages  
                            .entrySet()) {  
                        if (message.getKey().equals("Login")) {// 新用户登陆  
                            log(message.getValue() + " Login");  
                            for (Entry<String, HttpServletResponse> responseEntry:connections.entrySet()) {  
                                try {  
                                	
                                	//如果是当前登录用户
                                	if(StringUtils.equals(message.getValue().toString(), responseEntry.getKey())){
                                		continue;
                                	}
                                	
                                	HttpServletResponse response = responseEntry.getValue();
                                	response.setCharacterEncoding("UTF-8");
                                    PrintWriter writer = response  
                                            .getWriter();  
                                    writer  
                                            .print("<script type=\"text/javascript\">");  
                                    writer  
                                            .println("comet.welcomeMessage('Welcome "  
                                                    + message.getValue()  
                                                    + " join!');");  
                                    writer.println("comet.newUser('"  
                                            + message.getValue() + "');");  
                                    writer.print("</script>");  
                                    writer.flush();  
                                } catch (IOException e) {  
                                    log("IOExeption execute command", e);  
                                }  
                            }  
                        } else if ("Logout".equals(message.getKey())) {// 用户退出  
                            log(message.getValue() + " Logout");  
                            for (HttpServletResponse response : getConnections()  
                                    .values()) {  
                                try {  
                                	response.setCharacterEncoding("UTF-8");
                                    PrintWriter writer = response  
                                            .getWriter();  
                                    writer  
                                            .print("<script type=\"text/javascript\">");  
                                    writer.println("comet.newMessage('88, "  
                                            + message.getValue() + "');");  
                                    writer.println("comet.deleteUser('"  
                                            + message.getValue() + "');");  
                                    writer.print("</script>");  
                                    writer.flush();  
                                } catch (IOException e) {  
                                    log("IOExeption execute command", e);  
                                }  
                            }  
                        } else if ("*".equals(message.getKey())) {// 群发消息  
                            log("Send message: " + message.getValue()  
                                    + " to everyone.");  
                            for (HttpServletResponse response : getConnections()  
                                    .values()) {  
                                try {  
                                	response.setCharacterEncoding("UTF-8");
                                    PrintWriter writer = response  
                                            .getWriter();  
                                    writer  
                                            .print("<script type=\"text/javascript\">");  
                                    writer.println("comet.newMessage("  
                                            + message.getValue() + ");");  
                                    writer.print("</script>");  
                                    writer.flush();  
                                } catch (IOException e) {  
                                    log("IOExeption execute command", e);  
                                }  
                            }  
                        } else {// 向某人发信息  
                            try {  
                                HttpServletResponse response = getConnections()  
                                        .get(message.getKey());  
                                response.setCharacterEncoding("UTF-8");
                                PrintWriter writer = response.getWriter();  
                                writer  
                                        .print("<script type=\"text/javascript\">");  
                                writer.println("comet.privateMessage("  
                                        + message.getValue() + ");");  
                                writer.print("</script>");  
                                writer.flush();  
                            } catch (IOException e) {  
                                log("IOExeption sending message", e);  
                            }  
                        }  
                        // 从消息队列中删除消息  
                        messages.remove(message.getKey());  
                    }  
                }  
            }  
        }  
    }

	private void log(String string, IOException e) {
		System.out.println("----------log:" + string +";exception:" + e.getMessage());
	}

	private void log(String string) {
		System.out.println("----------log:" + string);
	}

	public void setConnections(Map<String, HttpServletResponse> connections) {
		this.connections = connections;
	}

	public Map<String, HttpServletResponse> getConnections() {
		return connections;
	}  
	
	public static MessageSender getMessageSenderInstance(){
		return messageSender;
	}
}  
