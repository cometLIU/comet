package com.jd.jos.comet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.apache.commons.lang.StringUtils;

public class MessageServlet extends HttpServlet {
    
	// 消息推送线程  
    protected static MessageSender messageSender = null;  
    
	public void init(){
		messageSender = MessageSender.getMessageSenderInstance();
		
	}
    protected void service(HttpServletRequest req, final HttpServletResponse resp) throws ServletException, IOException {
       String message = req.getParameter("message");
       String uid = req.getParameter("user");
       String currentUser = req.getParameter("currentUser");
       String chartType = req.getParameter("chartType");
       JSONObject messageObject = new JSONObject();
       messageObject.accumulate("message", message);
       messageObject.accumulate("currentUser", currentUser);
       if(StringUtils.equals(chartType, "all") || StringUtils.isBlank(chartType)){
    	   messageSender.send("*", messageObject.toString());
       }else {
    	   messageObject.accumulate("destUser", chartType);
    	   messageSender.send(chartType, messageObject.toString());
       }
       
    }
 
}
