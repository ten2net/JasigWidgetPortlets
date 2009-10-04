<%--

    Licensed to Jasig under one or more contributor license
    agreements. See the NOTICE file distributed with this work
    for additional information regarding copyright ownership.
    Jasig licenses this file to you under the Apache License,
    Version 2.0 (the "License"); you may not use this file
    except in compliance with the License. You may obtain a
    copy of the License at:

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on
    an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied. See the License for the
    specific language governing permissions and limitations
    under the License.

--%>
<%@ page contentType="text/html" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="portlet" uri="http://java.sun.com/portlet" %>
<%@ taglib prefix="rs" uri="http://www.jasig.org/resource-server" %>
<c:set var="n"><portlet:namespace/></c:set>

<script src="<rs:resourceURL value="/rs/jquery/1.3.1/jquery-1.3.1.min.js"/>" type="text/javascript"></script>
<script src="http://www.google.com/jsapi?key=${key}" type="text/javascript"></script>
<script type="text/javascript">
    google.load("feeds", "1");
    var ${n} = {
        jQuery: jQuery.noConflict(true)
    };
    
    ${n}.jQuery(function(){
        var $ = ${n}.jQuery;
        var feeds = new Array(<c:forEach items="${feedNames}" var="name" varStatus="status">{name: '${fn:replace(name, "'", "\\'")}', url: '${feedUrls[status.index]}'}${status.last ? "" : ", "}</c:forEach>)

	    var writeFeeds = function() {
	      document.getElementById("${n}feed").innerHTML = null;
	      var feedControl = new google.feeds.FeedControl();
	      feedControl.setLinkTarget(google.feeds.LINK_TARGET_BLANK);
	      ${n}.jQuery(feeds).each(function(){
	          feedControl.addFeed(this.url, this.name);
	      });
	      var options = (feeds.length > 1) ?  { drawMode: google.feeds.FeedControl.DRAW_MODE_TABBED } : { };
	      feedControl.draw(document.getElementById("${n}feed"), options);
	    }
	    google.setOnLoadCallback(writeFeeds);
        
	    var searchFeeds = function(form) {
	        $("#${n}feedSearchResults").html("");
	        google.feeds.findFeeds($(form.search).val(), feedSearchDone);
	        return false;
	    }
	    var feedSearchDone = function(result) {
	        $(result.entries).each(function(){
	            var li = $(document.createElement("li")).html(this.title);
	            var name = this.title.replace(/<b>|<\/b>/g, "");
	            li.append($(document.createElement("a")).html("<img src=\"<rs:resourceURL value="/rs/famfamfam/silk/1.3/feed_add.png"/>\" alt=\"Choose feed\" title=\"Choose feed\"/>")
	                .attr("href", this.url).attr("name", name).click(function(){ return addFeed(this); }));
	            $("#${n}feedSearchResults").append(li);
	        });
	    }
        var addFeed = function(el) {
            var html = "Name: <input name=\"name\" value=\"" + el.name + "\"/>, ";
            html += "url: <input name=\"url\" value=\"" + el.href + "\"/>";
            html += "<a href=\"#\" onclick=\"${n}.jQuery(this).parent().remove(); return false;\"><img src=\"<rs:resourceURL value="/rs/famfamfam/silk/1.3/feed_delete.png"/>\"/> Remove</a>";
            $("#${n}inputFeeds").append($(document.createElement("p")).html(html));
            return false;
        }
        var switchMode = function(mode) {
            $("#${n}view").css("display", (mode == "edit") ? "none" : "block");
            $("#${n}edit").css("display", (mode == "edit") ? "block" : "none");
            return false;
        }
	    var updateFeeds = function(form) {
	        var names = new Array();
	        var urls = new Array();
	        feeds = new Array();
	        $(form.name).each(function(){names.push(this.value);});
	        $(form.url).each(function(i){
               urls.push(this.value);
               feeds.push({ name: names[i], url: urls[i] }); 
	        });
	        $.post("<portlet:actionURL><portlet:param name="action" value="savePreferences"/></portlet:actionURL>", 
	            {feedNames: names, feedUrls: urls });
	        switchMode('view');
	        writeFeeds();
	        return false;
	    }
	    $("#${n}googleRss").ready(function(){
		    $("#${n}edit form:first").submit(function(){ return updateFeeds(this); });
            $("#${n}edit form:eq(1)").submit(function(){ return searchFeeds(this); });
            $("#${n}editLink").click(function(){ return switchMode('edit'); });
            $("#${n}viewLink").click(function(){ return switchMode('view'); });
            $("#${n}searchFeedsLink").toggle(
                function(){ $(this).next().css("display", "block"); $(this).find("img").attr("src", "<rs:resourceURL value="/rs/famfamfam/silk/1.3/bullet_toggle_plus.png"/>"); }, 
                function(){ $(this).next().css("display", "none");  $(this).find("img").attr("src", "<rs:resourceURL value="/rs/famfamfam/silk/1.3/bullet_toggle_minus.png"/>"); });
	    });
    });
</script>

<div id="${n}googleRss">
	<div id="${n}view">
	    <div id="${n}feed"></div>
	    <a id="${n}editLink" href="#"><img src="<rs:resourceURL value="/rs/famfamfam/silk/1.3/feed_edit.png"/>"/> Edit feeds</a>
	</div>
	
	<div id="${n}edit" style="display:none">
	    <h2>Edit feeds</h2>
	    <form name="${n}googlerss">
	        <div id="${n}inputFeeds">
		        <c:forEach items="${ feedNames }" var="name" varStatus="status">
		            <p>
		               Name: <input name="name" value="${ name }"/><br/>
		               URL: <input name="url" value="${ feedUrls[status.index] }"/><br/>
		               <a href="#" onclick="${n}.jQuery(this).parent().remove(); return false;"><img src="<rs:resourceURL value="/rs/famfamfam/silk/1.3/feed_delete.png"/>"/> Remove</a>
		            </p>
		        </c:forEach>
	        </div>
	        <input type="submit" value="Save"/>
	    </form>
	    <h2 id="${n}searchFeedsLink"><a href="javascript:;"><img src="<rs:resourceURL value="/rs/famfamfam/silk/1.3/bullet_toggle_plus.png"/>"/> Find new feeds</a></h2>
	    <div style="display:none">
		    <form name="${n}googlersssearch">
		        Search feeds: <input name="search"/> <input type="submit" value="Go!"/>
		    </form>
		    <ul id="${n}feedSearchResults"></ul>
	    </div>
	    <a id="${n}viewLink" href="#"><img src="<rs:resourceURL value="/rs/famfamfam/silk/1.3/arrow_left.png"/>"/> Back</a>
	</div>
</div>