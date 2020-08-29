<%@ page contentType="text/html; charset=utf-8" language="java"
         import ="org.ecocean.servlet.ServletUtilities,
         com.drew.imaging.jpeg.JpegMetadataReader,
         com.drew.metadata.Directory,
         org.ecocean.*,
         java.util.regex.Pattern,
         org.ecocean.servlet.ServletUtilities,
         org.json.JSONObject,
         org.json.JSONArray,
         javax.jdo.Extent, javax.jdo.Query,
         java.io.File, java.text.DecimalFormat,
         org.apache.commons.lang.StringEscapeUtils,
         java.util.*,org.ecocean.security.Collaboration" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
  String context="context0";
  context=ServletUtilities.getContext(request);
  Shepherd myShepherd = new Shepherd(context);
  myShepherd.setAction("project.jsp");
  String projId = request.getParameter("id").replaceAll("\\+", "").trim();
  String rootWebappPath = getServletContext().getRealPath("/");
  File webappsDir = new File(rootWebappPath).getParentFile();
  File shepherdDataDir = new File(webappsDir, CommonConfiguration.getDataDirectoryName(context));
  File projectsDir=new File(shepherdDataDir.getAbsolutePath()+"/projects");
  File projectDir = new File(projectsDir, projId);
  response.setHeader("Cache-Control", "no-cache"); //Forces caches to obtain a new copy of the page from the origin server
  response.setHeader("Cache-Control", "no-store"); //Directs caches not to store the page under any circumstance
  response.setDateHeader("Expires", 0); //Causes the proxy cache to see the page as "stale"
  response.setHeader("Pragma", "no-cache"); //HTTP 1.0 backward compatibility
  String langCode=ServletUtilities.getLanguageCode(request);
  pageContext.setAttribute("projId", projId);
  boolean proceed = true;
  boolean haveRendered = false;
  Properties collabProps = new Properties();
  String urlLoc = "//" + CommonConfiguration.getURLLocation(request);
  collabProps=ShepherdProperties.getProperties("collaboration.properties", langCode, context);
  User currentUser = AccessControl.getUser(request, myShepherd);
%>
<jsp:include page="../header.jsp" flush="true"/>
  <link rel="stylesheet" href="<%=urlLoc %>/cust/mantamatcher/css/manta.css"/>
    <title>Project <%=projId%></title>
    <%
      System.out.println("projectId is: " + projId);
      Project project = myShepherd.getProject(projId);
      List<Encounter> encounters = project.getEncounters();
      System.out.println("project acquired! It is:");
      System.out.println(project.toString());
    %>
    <div class="container maincontent">
          <%
          try{
            if(currentUser != null){
              System.out.println("projectname is " + project.getResearchProjectName());
              %>
              <h3>Project: <%=project.getResearchProjectName()%></h3>
              <%
              System.out.println("got here");
              if(encounters == null || encounters.size()<1){
                System.out.println("got here null or empty");
                %>
                  <h4>You don't have any encounters in this project yet</h4>
                <%
              }else{
                System.out.println("not null");
                %>
                <div align="center">
                  <table class="row tissueSample">
                    <thead>
                      <tr>
                        <th class="tissueSample">Encounter</th>
                        <th class="tissueSample">Individual</th>
                        <th class="tissueSample">Date/Time</th>
                        <th class="tissueSample">Location</th>
                        <th class="tissueSample">Data Owner</th>
                        <th class="tissueSample">Project IDs</th>
                        <th class="tissueSample">Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                <%
                if(encounters!=null && encounters.size()>0){
                  System.out.println("not null again");
                  for(int i=0; i<encounters.size(); i++){
                    %>
                    <tr>
                    <%
                    String location = "";
                    if(encounters.get(i).getLocationID() != null){
                      System.out.println("locationID is not null");
                      location = encounters.get(i).getLocationID();
                    }
                    String individualDisplayName = "";
                    if(encounters.get(i).getIndividual() != null){
                      individualDisplayName = encounters.get(i).getIndividual().getDisplayName();
                    }
                    String dataOwner = "";
                    if(encounters.get(i).getAssignedUsername() !=null){
                      dataOwner = encounters.get(i).getAssignedUsername();
                    }
                    String encounterDate = "";
                    if(encounters.get(i).getDate()!= null){
                      encounterDate = encounters.get(i).getDate();
                    }
                    %>
                    <td class="tissueSample"><%=encounters.get(i).getCatalogNumber()%></td>
                    <td class="tissueSample"><%=individualDisplayName%></td>
                    <td class="tissueSample"><%=encounterDate%></td>
                    <td class="tissueSample"><%=location%></td>
                    <td class="tissueSample"><%=dataOwner%></td>
                    <td class="tissueSample">
                    <%
                      List<String> researchProjectIds = myShepherd.getResearchProjectIdsForEncounter(encounters.get(i));
                      for(int j=0; j<researchProjectIds.size(); j++){
                        %>
                        <%= researchProjectIds.get(j) %>
                        <%
                      }
                      %>
                    </td>
                    <td class="tissueSample">
                      <button type="button">Project Match</button>
                      </br>
                      <button type="button" onclick="markNew('<%= encounters.get(i).getCatalogNumber()%>')">Mark New</button>
                    </td>
                    </tr>
                    <%
                  }
                }
              }
            }
          }
          catch(Exception e){
            e.printStackTrace();
          }
          finally{
          }
          %>
              </tbody>
            </table>
          </div>
    </div>
<jsp:include page="../footer.jsp" flush="true"/>

<script type="text/javascript">
function markNew(projectId){
  console.log("markNew clicked!");
  console.log("projectId is " + projectId);
}
</script>
