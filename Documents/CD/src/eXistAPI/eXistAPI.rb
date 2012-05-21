require "xmlrpc/client"
$:.unshift(".")
require 'collection'

#ExistAPI is comunication interface to eXist-db based on XML-RPC. With eXistAPI 
#you are able to create, delete or get collections or retrieve whole content of 
#documents or part of it by querying. 
#Also with eXistAPI you can work with documents stored in eXist-db. 
#You can insert, replace, rename and delete nodes or change values.
#To query use xQuery or xPath.
#
#
# ==== Examples
#db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
#puts db.existscollection?("db")
class ExistAPI
  
  #Create new instance of ExistAPI.
  #
  #example ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")    
  #
  # * *Args*    :
  #   - +uri+ -> uri of the db server
  #   - +username+ -> username
  #   - +password+  -> password to specified username
  # * *Returns* :
  #   - new instance of ExistAPI
  # * *Raises* :
  #   - +ExistException+ -> Database login failed
  #
  def initialize(uri = nil , username = nil, password = nil)
    @uri = uri
    @username = username
    @password = password
    @parameters = { "encoding" => "UTF-8", "indent" => "yes"}
    connect
  end

  private

  #Creates collection with name in parrent collection(optionaly)#
  #
  # * *Args*    :
  #   - +name+ -> the name of collection
  # * *Returns* :
  #   - the result of call
  # * *Raises* :
  #   - +ExistException+ -> Database login failed
  #
  def connect
    @client = XMLRPC::Client.new2(@uri)
    @client.user=(@username)
    @client.password=(@password)
    @client.call("isXACMLEnabled")  #test if the connection is established.
  rescue XMLRPC::FaultException => e
    raise e    
  rescue
    raise ExistException.new("Database login failed", 1), caller
  end
  
  #Checks if path starts and ends with "/". If not, adds "/".
  #
  # * *Args*    :
  #   - +path+ -> the path of collection
  # * *Returns* :
  #   - Path with "/" at the begging and end.
  # * *Raises* :
  #   - +ArgumentError+ -> if any value is nil or negative
  #
  def check_slashes(path)
    if(path[0] != "/")
      path = "/" + path
    end
    if(path[-1] != "/")    #if last is not "/" then add it
      path += "/"
    end
    return path
  end
  
  
  public
  
  #Creates collection with name in parrent(optionaly)
  #
  # * *Args*    :
  #   - +name+ -> the name of collection
  # * *Returns* :
  #   - the result of call
  # * *Raises* :
  #   - +ExistException+ -> if collection is not created.
  #
  def createcollection(name, parent_col = nil)
    name = check_slashes(name)
    if (parent_col == nil)
      begin
        result = @client.call("createCollection", name)
        return result
      end
    else
      begin
        colname = parent_col.name + name
        result = @client.call("createCollection", colname)
        return result
      end
    end
  rescue XMLRPC::FaultException => e
    raise e    
  rescue
    raise ExistException.new("Failed to create Collection", 2), caller
  end
  
  #Returns Collection at specified path.
  #
  # * *Args*    :
  #   - +path+ -> Path of the collection in db.
  # * *Returns* :
  #   -instance of class Collection.
  # * *Raises* :
  #   - +nothing+
  #
  def getcollection(path)
    path = check_slashes(path)
    col = Collection.new(@client, path)
    return col
  rescue  => e
    raise e  
  end
  
  #Checks if collection with path exists or not.
  #
  # * *Args*    :
  #   - +path+ -> Path of the collection in db.
  # * *Returns* :
  #   -boolean. true -> exists, false -> doesn't exist
  # * *Raises* :
  #   - +nothing+
  #
  def existscollection?(orig_path)
    orig_path = check_slashes(orig_path)
    collections = orig_path.split("/")
    collections.delete("")
    i=0
    path = "/" 
    while(i < collections.length)
      path = path + collections[i] + "/"
      col = Collection.new(@client, path)
      if (!col.childCollection.include?(collections[i+1]))
        break
      end
      i = i + 1
    end
    
    if(path[-1]=="/")
      path = path[0..-2]
    end
    if(orig_path[-1]=="/")
      orig_path = orig_path[0..-2]
    end
    
    if(path == orig_path)
      return true
    else
      return false
    end
  rescue  => e
    raise e  
  end

  
  #Removes collection with specified path.
  #
  # * *Args*    :
  #   - +path+ -> Path of the collection in db.
  # * *Returns* :
  #   - the result of call
  # * *Raises* :
  #   - +ExistException+ -> if failed to remove collection.
  #
  def remove_collection(path)
    result = @client.call("removeCollection", path)
    return result
  rescue XMLRPC::FaultException => e
    raise e    
  rescue
    raise ExistException.new("Failed to remove Collection", 3), caller
  end
  
  #Stores resource to document in db.
  #Inserts a new document into the database or replace an existing one:
  #
  # * *Args*    :
  #   - +_res+ -> resource which you want to safe. XML content of this document as a UTF-8 encoded byte array.
  #   - +_docname+ -> name of the document where to safe. Path to the database location where the new document is to be stored.
  #   - +_overwrite+ -> Set this value to > 0 to automatically replace an existing document at the same location.
  # * *Returns* :
  #   - boolean, the result of the call 
  # * *Raises* :
  #   - +ExistException+ -> Resource or document name is nil
  #   - +ExistException+ -> Failed to store resource"
  def storeresource(_res, _docname, _overwrite = 1)
    if ((_res == nil)||(_docname == nil))
      raise ExistException.new("Resource or document name is nil", 4), caller
    end
    begin
      @client.call("parse",_res.to_s, _docname, _overwrite)
    rescue XMLRPC::FaultException => e
      raise e    
    rescue ExistException => e
      raise e
    rescue
      raise ExistException.new("Failed to store resource", 5), caller
    end
  end
  
  #Executes an XQuery and returns a reference identifier to the generated result set. This reference can be used later to retrieve results.
  #
  # * *Args*    :
  #   - +xquery+ -> String xquery. A valid XQuery expression.
  #   - +parameters+ -> HashMap parameters. The parameters a HashMap values.
  #sort-expr :
  #namespaces :
  #variables :
  #base-uri :
  #static-documents :
  #protected : 
  # * *Returns* :
  #   -int, handle of query
  # * *Raises* :
  #   - +ExistException+ -> Failed to execute query
  #
  def execute_query(xquery, parameters = @parameters)
    #puts xquery
    begin
      handle = @client.call("executeQuery", XMLRPC::Base64.new(xquery), parameters)
      return handle
    rescue XMLRPC::FaultException => e
      raise e    
    rescue
      raise ExistException.new("Failed to execute query", 6), caller
    end
  end
  
  #Retrieves a single result-fragment from the result-set referenced by resultId. 
  #The result-fragment is identified by its position in the result-set, which is passed in the parameter pos.
  #
  # * *Args*    :
  #   - +handle+ -> Reference to a result-set as returned by a previous call to executeQuery.
  #   - +pos+ -> The position of the item in the result-sequence, starting at 0.
  #   - +parameters+ -> A struct containing key=value pairs to configure the output.
  # * *Returns* :
  #   - the result of call
  # * *Raises* :
  #   - +ExistException+ -> Failed to retrive resource
  #
  def retrieve(handle, pos)
    begin
      res = @client.call("retrieve", handle, pos, @parameters)
      return res
    rescue XMLRPC::FaultException => e
      raise e   
    rescue
      raise ExistException.new("Failed to retrive resource", 7), caller
    end
  end
  
  #Get the number of hits in the result-set identified by resultId.
  #example: gethits(handle_id)
  #
  # * *Args*    :
  #   - +handle+ -> Reference to a result-set as returned by a previous call to executeQuery.
  # * *Returns* :
  #   -the number of hits
  # * *Raises* :
  #   - +ExistException+ -> Failed to get number of hits
  #
  def get_hits(handle)
    begin
      summary = @client.call("querySummary", handle)
      hits = summary['hits']
      return hits
    rescue XMLRPC::FaultException => e
      raise e
    rescue
      raise ExistException.new("Failed to get number of hits", 8), caller
    end
  end
  
  #Inserts the content sequence specified in expr into the element node passed 
  #via exprSingle. exprSingle and expr should evaluate to a node set. 
  #If exprSingle contains more than one element node, the modification will be 
  #applied to each of the nodes. The position of the insertion is determined by 
  #the keywords "into", "following" or "preceding":
  #
  #
  # * *Args*    :
  #   - +expr+ -> The content is appended after the last child node of the specified elements.
  #   e.g.: <email type="office">andrew@gmail.com</email>, 
  #   - +pos+ -> The content is inserted immediately after the node specified in exprSingle.
  #   pos = "into" | "following" | "preceding"
  #   - +expr_single+ -> The content is inserted before the node specified in exprSingle.
  #   e.g. '//address[fname="Andrew"]'
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +nothing+
  def update_insert(expr, pos, expr_single) 
    query = "update insert "+expr+" "+pos+" "+expr_single
    #puts "query #{query}"
    execute_query(query)
  rescue  => e
    raise e    
  end
  
  #Replaces the nodes returned by expr with the nodes in exprSingle. 
  #expr may evaluate to a single element, attribute or text node. 
  #If it is an element, exprSingle should contain a single element node as well. 
  #If it is an attribute or text node, the value of the attribute or the text 
  #node is set to the concatenated string values of all nodes in exprSingle.
  #
  # * *Args*    :
  #   - +expr+ -> e.g.: //fname[. = "Andrew"]
  #   - +expr_single+ -> <fname>Andy</fname>
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +nothing+
  #
  def update_replace(expr, expr_single)
    query = "update replace "+expr+" with "+expr_single
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  #Updates the content of all nodes in expr with the items in exprSingle. 
  #If expr is an attribute or text node, its value will be set to the 
  #concatenated string value of all items in exprSingle.
  #
  # * *Args*    :
  #   - +expr+ -> "//node()[@id="RockyRacoon"]/@id"
  #   - +expr_single+ -> '"RockyR"'
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +nothing+
  #
  def update_value(expr, expr_single)
    query = "update replace " + expr + " with " + expr_single
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  #Removes all nodes in expr from their document.
  #
  # * *Args*    :
  #   - +expr+ -> "//node()[@id="RockyRacoon"]
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +nothing+
  #
  def update_delete(expr)
    query = "update delete " + expr
    #puts "query #{query}"
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  #Renames the nodes in expr using the string value of the first item in 
  #exprSingle as the new name of the node. expr should evaluate to a set of 
  #elements or attributes.
  #
  # * *Args*    :
  #   - +expr+ -> //city
  #   - +expr_single+ -> "town"
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +nothing+ ->
  #
  def update_rename(expr, expr_single)
    query = "update rename " + expr + " as " + expr_single
    #puts "query #{query}"
    execute_query(query)
  rescue  => e
    raise e  
  end
end
