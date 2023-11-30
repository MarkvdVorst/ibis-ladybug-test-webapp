<%@ page import="nl.nn.testtool.TestTool"%>
<%@ page import="nl.nn.testtool.storage.LogStorage"%>
<%@ page import="org.springframework.web.context.WebApplicationContext"%>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@ page import="javax.xml.transform.stream.StreamSource" %>
<%@ page import="javax.xml.transform.Transformer" %>
<%@ page import="net.sf.saxon.trans.XsltController" %>
<%@ page import="net.sf.saxon.lib.StandardLogger" %>
<%@ page import="javax.xml.transform.stream.StreamResult" %>
<%@ page import="javax.xml.transform.Result" %>
<%@ page import="org.apache.xalan.trace.TraceManager" %>
<%@ page import="org.wearefrank.xsltdebugger.trace.SaxonTemplateTraceListener" %>
<%@ page import="org.wearefrank.xsltdebugger.trace.XalanTemplateTraceListener" %>
<%@ page import="org.wearefrank.xsltdebugger.XSLTTraceReporter" %>
<%@ page import="org.wearefrank.xsltdebugger.trace.SaxonTemplateTraceListener" %>
<%@ page import="org.wearefrank.xsltdebugger.trace.XalanTemplateTraceListener" %>
<%@ page import="org.wearefrank.xsltdebugger.XSLTTraceReporter" %>
<%@ page import="org.wearefrank.xsltdebugger.XSLTReporterSetup" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.*" %>
<%
	ServletContext servletContext = request.getSession().getServletContext();
	WebApplicationContext webApplicationContext = WebApplicationContextUtils.getWebApplicationContext(servletContext);
	TestTool testTool = (TestTool)webApplicationContext.getBean("testTool");
	String correlationId = UUID.randomUUID().toString();
	String otherCorrelationId = UUID.randomUUID().toString();
	String reportName;
	List<String> reportNames = new ArrayList<String>();
	String userName = null;

	if (request.getUserPrincipal() != null) {
		userName = request.getUserPrincipal().getName();
	}

	// Create report links
	String createReportAction = request.getParameter("createReport");
	reportNames.add(reportName = "xsltsetup SAXON");
	if(reportName.equals(createReportAction)){
		try {
			ClassLoader classLoader = Thread.currentThread().getContextClassLoader();

			URL xmlURL = classLoader.getResource("/tree.xml");
			URL xslURL = classLoader.getResource("/treeXSL.xsl");

			assert Objects.requireNonNull(xmlURL).getFile() != null;
			assert Objects.requireNonNull(xslURL).getFile() != null;

			File xmlFile = new File(xmlURL.getFile());
			File xslFile = new File(xslURL.getFile());

			XSLTReporterSetup reporterSetup = new XSLTReporterSetup(xmlFile, xslFile, 2);
			reporterSetup.transform();

			XSLTTraceReporter.initiate(testTool, reporterSetup, correlationId, reportName);
		}catch (Exception e){
			throw new RuntimeException(e);
		}
	}

	reportNames.add(reportName = "xsltsetup XALAN");
	if(reportName.equals(createReportAction)){
		try {
			ClassLoader classLoader = Thread.currentThread().getContextClassLoader();

			URL xmlURL = classLoader.getResource("/foo.xml");
			URL xslURL = classLoader.getResource("/foo.xsl");

			if(xmlURL == null){
				throw new Exception("XML file not found");
			}
			if(xslURL == null){
				throw new Exception("XSL file not found");
			}

			File xmlFile = new File(xmlURL.getFile());
			File xslFile = new File(xslURL.getFile());

			XSLTReporterSetup reporterSetup = new XSLTReporterSetup(xmlFile, xslFile, 1);
			reporterSetup.transform();

			XSLTTraceReporter.initiate(testTool, reporterSetup, correlationId, reportName);
		}catch (Exception e){
			throw new RuntimeException(e);
		}
	}

	reportNames.add(reportName = "Simple report");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(correlationId, null, reportName, "Hello World!");
		testTool.endpoint(correlationId, null, reportName, "Goodbye World!");
	}
	reportNames.add(reportName = "Another simple report");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(otherCorrelationId, null, reportName, "Hello World!");
		testTool.endpoint(otherCorrelationId, null, reportName, "Goodbye World!");
	}
	reportNames.add(reportName = "Report with empty string as name");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(otherCorrelationId, null, "", "Hello World!");
		testTool.endpoint(otherCorrelationId, null, "", "Goodbye World!");
	}
	reportNames.add(reportName = "Report with null as name");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(otherCorrelationId, null, null, "Hello World!");
		testTool.endpoint(otherCorrelationId, null, null, "Goodbye World!");
	}
	reportNames.add(reportName = "Message is captured asynchronously from a character stream");
	if (reportName.equals(createReportAction)) {
		testTool.setCloseMessageCapturers(true);
		testTool.setCloseThreads(true);
		testTool.startpoint(correlationId, null, reportName, "Hello World!");
		Writer writerMessage = testTool.inputpoint(correlationId, null, "writer", new StringWriter());
		writerMessage.write("Passing by the world!");
		testTool.endpoint(correlationId, null, reportName, "Goodbye World!");
		testTool.close(correlationId);
		writerMessage.close();
	}
	reportNames.add(reportName = "Message is null");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(correlationId, null, reportName, "Hello World!");
		testTool.infopoint(correlationId, null, "Null String", null);
		testTool.setMessageEncoder(testTool.getMessageEncoder());
		testTool.endpoint(correlationId, null, reportName, "Goodbye World!");
	}
	reportNames.add(reportName = "Message is an empty string");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(correlationId, null, reportName, "Hello World!");
		testTool.infopoint(correlationId, null, "Empty String", "");
		testTool.setMessageEncoder(testTool.getMessageEncoder());
		testTool.endpoint(correlationId, null, reportName, "Goodbye World!");
	}
	reportNames.add(reportName = "Hide a checkpoint in blackbox view");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(correlationId, null, reportName, "Hello World!");
		testTool.infopoint(correlationId, null, "Hide this checkpoint", "");
		testTool.setMessageEncoder(testTool.getMessageEncoder());
		testTool.endpoint(correlationId, null, reportName, "Goodbye World!");
	}
	reportNames.add(reportName = "Message encoded using Base64");
	if (reportName.equals(createReportAction)) {
		byte[] message = new byte[6];
		// Two bytes for ë in UTF-8
		message[0] = (byte)195;
		message[1] = (byte)171;
		// Two bytes for © in UTF-8
		message[2] = (byte)194;
		message[3] = (byte)169;
		// One byte for ë in ISO-8859-1
		message[4] = (byte)235;
		// One byte for © in ISO-8859-1
		message[5] = (byte)169;
		// The last two bytes cannot be encoded in UTF-8 so Ladybug will use Base64 instead
		testTool.startpoint(correlationId, null, reportName, message);
		// Remove last two bytes so message can be encoded using UTF-8 by Ladybug
		message = Arrays.copyOf(message, 4);
		testTool.infopoint(correlationId, null, reportName, message);
		// Test Unicode supplementary characters with a smiley :)
		message[0] = (byte)240;
		message[1] = (byte)159;
		message[2] = (byte)152;
		message[3] = (byte)138;
		testTool.endpoint(correlationId, null, reportName, message);
	}
	reportNames.add(reportName = "Waiting for thread to start");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(correlationId, null, reportName, "message");
		testTool.threadCreatepoint(correlationId, "123");
	}
	reportNames.add(reportName = "Waiting for message to be captured");
	if (reportName.equals(createReportAction)) {
		testTool.startpoint(correlationId, null, reportName, new ByteArrayInputStream(new byte[0]));
	}

	// Other actions
	if ("true".equals(request.getParameter("clearDebugStorage"))) {
		LogStorage debugStorage = (LogStorage)webApplicationContext.getBean("debugStorage");
		debugStorage.clear();
	}
	if (request.getParameter("changeDebugStorage") != null) {
		testTool.setDebugStorage((LogStorage)testTool.getStorage(request.getParameter("changeDebugStorage")));
	}
	if (request.getParameter("removeReportInProgress") != null) {
		int nr = Integer.valueOf(request.getParameter("removeReportInProgress"));
		testTool.removeReportInProgress(nr -1);
	}
%>
<html>

  <h1>Browse</h1>

  <a href="testtool">Old Echo2 GUI</a><br/>

  <br/>

  <a href="ladybug">New Angular GUI</a><br/>
  <a href="http://localhost:4200">New Angular GUI using Node.js</a><br/>

  <br/>

  <a href="ladybug/api/testtool">TestTool API</a><br/>
  <a href="http://localhost:4200/api/testtool">TestTool API proxied by Node.js</a><br/>

  <br/>

  <a href="ladybug/api/metadata">Metadata API</a><br/>
  <a href="http://localhost:4200/api/metadata">Metadata API proxied by Node.js</a><br/>

  <br/>

  <a href="https://github.com/ibissource/ibis-ladybug/tree/master/src/main/java/nl/nn/testtool/web/api">More API info</a><br/>


  <h1>Create report</h1>

  <% for (String name : reportNames) { %>
  <a href="index.jsp?createReport=<%=name%>"><%=name%></a><br/>
  <% } %>


  <h1>Other actions</h1>

  <a href="index.jsp?clearDebugStorage=true">Clear debug storage</a><br/>
  <a href="index.jsp?changeDebugStorage=databaseStorage">Change debug storage to database storage</a><br/>
  <a href="index.jsp?removeReportInProgress=1">Remove report in progress number 1</a><br/>
  <a href="h2">Manage H2 database</a> (leave User Name and Password empty but make sure the JDBC URL is filled with the URL from springTestToolTestWebapp.xml)<br/>


  <h1>Debug info</h1>

  Logged in user: <%= userName %><br/>

  <br/>

  Name: <%= testTool.getName() %><br/>
  Version: <%= testTool.getVersion() %><br/>
  SpecificationVersion: <%= testTool.getSpecificationVersion() %><br/>
  ImplementationVersion: <%= testTool.getImplementationVersion() %><br/>
  ConfigName: <%= testTool.getConfigName() %><br/>
  ConfigVersion: <%= testTool.getConfigVersion() %><br/>

  <br/>

  ReportGeneratorEnabled: <%= testTool.isReportGeneratorEnabled() %><br/>
  RegexFilter: <%= testTool.getRegexFilter() %><br/>

  <br/>

  NumberOfReportsInProgress: <%= testTool.getNumberOfReportsInProgress() %><br/>
  ReportsInProgressEstimatedMemoryUsage: <%= testTool.getReportsInProgressEstimatedMemoryUsage() %><br/>

  <br/>

  DebugStorage: <%= testTool.getDebugStorage() %><br/>
  DebugStorage size: <%= testTool.getDebugStorage().getSize() %><br/>
  TestStorage: <%= testTool.getTestStorage() %><br/>
  TestStorage size: <%= testTool.getTestStorage().getSize() %><br/>

  <br/>

  Debugger: <%= testTool.getDebugger() %><br/>
  Rerunner: <%= testTool.getRerunner() %><br/>

  <br/>

  Views: <%= testTool.getViews() %><br/>
  StubStrategies: <%= testTool.getStubStrategies() %><br/>
  DefaultStubStrategy: <%= testTool.getDefaultStubStrategy() %><br/>
  MatchingStubStrategiesForExternalConnectionCode: <%= testTool.getMatchingStubStrategiesForExternalConnectionCode() %><br/>

  <br/>

  MaxCheckpoints: <%= testTool.getMaxCheckpoints() %><br/>
  MaxMemoryUsage: <%= testTool.getMaxMemoryUsage() %><br/>
  MaxMessageLength: <%= testTool.getMaxMessageLength() %><br/>

  <br/>

  MessageTransformer: <%= testTool.getMessageTransformer() %><br/>
  MessageEncoder: <%= testTool.getMessageEncoder() %><br/>
  MessageCapturer: <%= testTool.getMessageCapturer() %><br/>
  CloseMessageCapturers: <%= testTool.isCloseMessageCapturers() %><br/>
  CloseThreads: <%= testTool.isCloseThreads() %><br/>

  <br/>

  SecurityLog: <%= testTool.getSecurityLog() %><br/>

  <br/>

  Default charset: <%= java.nio.charset.Charset.defaultCharset() %><br/>
  File encoding: <%= System.getProperty("file.encoding") %><br/>

</html>
