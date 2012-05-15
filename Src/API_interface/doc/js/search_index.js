var search_data = {"index":{"searchIndex":["api_interface","collection","document","content()","createcollection()","docs()","execute_query()","existscollection?()","get_hits()","getcollection()","new()","new()","new()","remove_collection()","retrieve()","storeresource()","update_delete()","update_insert()","update_value()","license","readme","rakefile","rake-d"],"longSearchIndex":["api_interface","collection","document","document#content()","api_interface#createcollection()","collection#docs()","api_interface#execute_query()","api_interface#existscollection?()","api_interface#get_hits()","api_interface#getcollection()","api_interface::new()","collection::new()","document::new()","api_interface#remove_collection()","api_interface#retrieve()","api_interface#storeresource()","api_interface#update_delete()","api_interface#update_insert()","api_interface#update_value()","","","",""],"info":[["API_interface","","API_interface.html","","<p>API is comunication interface between RubyACL and Database that supports\nxQuery  and xPath.  API should ...\n"],["Collection","","Collection.html","",""],["Document","","Document.html","",""],["content","Document","Document.html#method-i-content","()","<p>Returns content of document in db. Usually document is xml. Retrieves a\ndocument from the database.\n\n<pre>* ...</pre>\n"],["createcollection","API_interface","API_interface.html#method-i-createcollection","(collection_path)","<p>Creates collection with name in parrent(optionaly)\n\n<pre>* *Args*    :\n  - +name+ -&gt; the name of collection ...</pre>\n"],["docs","Collection","Collection.html#method-i-docs","()","<p>Returns string of collection. That inclunde permissions, owner, group and\nname.\n\n<pre>* *Args*    :\n  - +none+ ...</pre>\n"],["execute_query","API_interface","API_interface.html#method-i-execute_query","(query)","<p>Executes an XQuery and returns a reference identifier to the generated\nresult set. This reference can ...\n"],["existscollection?","API_interface","API_interface.html#method-i-existscollection-3F","(collection_path)","<p>Checks if collection with path exists or not.\n\n<pre>* *Args*    :\n  - +path+ -&gt; Path of the collection in db. ...</pre>\n"],["get_hits","API_interface","API_interface.html#method-i-get_hits","(handle)","<p>Get the number of hits in the result-set identified by resultId. example:\ngethits(handle_id)\n\n<pre>* *Args* ...</pre>\n"],["getcollection","API_interface","API_interface.html#method-i-getcollection","(collection_path)","<p>Returns Collection at specified path.\n\n<pre>* *Args*    :\n  - +path+ -&gt; Path of the collection in db.\n* *Returns* ...</pre>\n"],["new","API_interface","API_interface.html#method-c-new","(uri = nil , username = nil, password = nil)","<p>Create new instance of ExistAPI.\n<p>example ExistAPI.new(\"localhost:8080/exist/xmlrpc\", \"admin\", ...\n"],["new","Collection","Collection.html#method-c-new","(client, collectionName)","<p>Creates new collection.\n\n<pre>* *Args*    :\n  - +client+ -&gt; e.g. ExistAPI.new(&quot;http://localhost:8080/exist/xmlrpc&quot;, ...</pre>\n"],["new","Document","Document.html#method-c-new","(client, hash, colname)","<p>Creates new instance of document\n\n<pre>* *Args*    :\n  - +client+ -&gt; e.g. ExistAPI.new(&quot;http://localhost:8080/exist/xmlrpc&quot;, ...</pre>\n"],["remove_collection","API_interface","API_interface.html#method-i-remove_collection","(_name)","<p>Removes collection with specified path.\n\n<pre>* *Args*    :\n  - +path+ -&gt; Path of the collection in db.\n* *Returns* ...</pre>\n"],["retrieve","API_interface","API_interface.html#method-i-retrieve","(handle, result_id)","<p>Retrieves a single result-fragment from the result-set referenced by\nresultId.  The result-fragment is ...\n"],["storeresource","API_interface","API_interface.html#method-i-storeresource","(xml_source_file, document_path_in_db)","<p>Stores resource to document in db. Inserts a new document into the database\nor replace an existing one: ...\n"],["update_delete","API_interface","API_interface.html#method-i-update_delete","(expression)","<p>Removes all nodes in expr from their document.\n\n<pre>* *Args*    :\n  - +expr+ -&gt; &quot;//node()[@id=&quot;RockyRacoon&quot;] ...</pre>\n"],["update_insert","API_interface","API_interface.html#method-i-update_insert","(expression, position, expression_location)","<p>Inserts the content sequence specified in expr into the element node passed\nvia exprSingle. exprSingle ...\n"],["update_value","API_interface","API_interface.html#method-i-update_value","(expr_value_identification, expr_new_value)","<p>Updates the content of all nodes in expr with the items in exprSingle.  If\nexpr is an attribute or text ...\n"],["LICENSE","","LICENSE.html","","<p>API_interface\n<p>Put appropriate LICENSE for your project here.\n"],["README","","README.html","","<p>API_interface - interface for Ruby-ACL\n<p>github  &mdash; github.com/sirljan/Ruby-ACL/tree/master/Src/API_interface ...\n\n"],["Rakefile","","Rakefile.html","","<p>#  # To change this template, choose Tools | Templates # and open the\ntemplate in the editor.\n<p>require ...\n"],["rake-d","","nbproject/private/rake-d_txt.html","",""]]}}