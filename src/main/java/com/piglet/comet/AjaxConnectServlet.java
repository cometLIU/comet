package com.piglet.comet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;

public class AjaxConnectServlet extends HttpServlet {

	@Override
	protected void service(HttpServletRequest request, final HttpServletResponse response) throws ServletException,IOException {
		response.setHeader("Connection", "Keep-Alive");
	    response.setHeader("Proxy-Connection", "Keep-Alive");
	    response.setHeader("Cache-Control", "private");
	    response.setHeader("Pragma", "no-cache");
	    
	    final PrintWriter writer = response.getWriter();
	    for(int i=0;i<1000;i++){
	    	writer.write("hellword" + i);
	  	    writer.flush();
	  	    try {
				Thread.sleep(3000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }
  }
	
}
