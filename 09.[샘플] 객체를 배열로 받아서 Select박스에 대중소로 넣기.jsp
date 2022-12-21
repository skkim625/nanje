<%@ page import="com.netville.blog.component.blogfamily.client.BlogFamilyClientHelper"  %>
<%@ page import="com.netville.blog.component.blogfamily.model.BlogFamily"               %>
<%@ page import="com.netville.blog.component.blogfamily.model.BlogFamilyGroup"          %>


<%
 BlogClientHelper helper = new BlogClientHelper();
 BlogFamilyClientHelper familyHelper = new BlogFamilyClientHelper();
 
 BlogFamilyGroup blogFamily[] = familyHelper.getBlogFamily(blogId);
    int groupCnt = blogFamily.length;
%>


<SCRIPT LANGUAGE="JavaScript">
//document.domain = "moneta.co.kr";
var neighbor_id   = new Array();
var neighbor_name = new Array();

<%
    // �׷쿡 ���� �̿������� array �� ��´�.
    int group_index  = 0;
    int family_index = 0;
    
    int familySize = 0;
    
    String temp_id   = "";
    String temp_name = "";
    
 for ( group_index=0 ; group_index < groupCnt; group_index++) {
        int group_id = blogFamily[group_index].getGroup_id();
        
        List temp = blogFamily[group_index].getBlog_family();
        
        familySize=0;                
        if(temp!=null){
            familySize = temp.size();

%>
    neighbor_id  [<%=group_index%>] = new Array();
    neighbor_name[<%=group_index%>] = new Array();
<%
            if(familySize<1){
%>
    neighbor_id  [<%=group_index%>][0] = "0";
    neighbor_name[<%=group_index%>][0] = "�̿��� �����ϴ�.";
<%
            }else{            
                for(family_index=0; family_index < familySize; family_index++ ){
                    BlogFamily tfamily = (BlogFamily)temp.get(family_index);                    
                    temp_id   = tfamily.getNeighbor_id();
                    temp_name = tfamily.getFamily_nick_name();
%>
    neighbor_id  [<%=group_index%>][<%=family_index%>] = "<%=temp_id%>";
    neighbor_name[<%=group_index%>][<%=family_index%>] = "<%=temp_name%>";
<%
                }
            }
        }
    }
%>
 
 /*** �̿�����-'���ã�� �̿��׷�'�� �ٲ� ��� ***/
 function changeFirstSection() {
  var obj = document.pop_present_form.group_neighbor_id;
  
  //�̿����� ����
  selectRemoveAll(obj, true);
  
  var index = document.pop_present_form.group_id.selectedIndex;
  
  for(i=0; i<neighbor_id[index].length; i++){
      obj.add(new Option(neighbor_name[index][i],neighbor_id[index][i]),i); 
  }

 }
 
 /*** �޺��ڽ��� ����ִ� ��ü ����� ***/
 function selectRemoveAll(obj,zeroIndexDelete)  { 
  index = zeroIndexDelete?0:1; 

  Length = obj.options.length; 
  if(Length==0) { 
   return; 
  } 

  for(var i = obj.options.length-1 ; i >= 0;i--) {
   obj.remove(i);
  }
  return;
 }
</SCRIPT>

 

     ���ã�� �̿� ���� 
 <select name="group_id" onChange="javascript:changeFirstSection();">
 <%       
  if(groupCnt==0) out.println("<option value='0'>�̿��׷��� �����ϴ�.</option>");
  
  // �׷����� ��������
  for ( int i = 0 ; i < groupCnt; i++) {
 
   int group_id      = blogFamily[i].getGroup_id();
   String group_name = blogFamily[i].getGroup_name();
 
 %>
   <option value="<%=group_id%>"><%=group_name%></option>
 <%
  }
 %>
 </select>

 <%
  List temp_family = null;
       
  if(groupCnt<1){
   out.println("<option value='0'>�̿��� �����ϴ�.</option>");
  }else{
   temp_family = blogFamily[0].getBlog_family();
  }
  
  for(int i=0; temp_family!=null && i<temp_family.size(); i++ ){
   BlogFamily family = (BlogFamily)temp_family.get(i);
   
   String neighbor_id   = family.getNeighbor_id();
   String neighbor_name = family.getFamily_nick_name();
 %>
  <option value="<%=neighbor_id%>"><%=neighbor_name%></option>
 <%
  }
 %>
 </select>

 
