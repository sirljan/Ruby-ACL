require "xmlrpc/client"
require 'collection'

class ExistAPI
  @uri
  @username
  @password
  @client

  #
  def initialize(uri = nil , username = nil, password = nil)
    @uri = uri
    @username = username
    @password = password
    @parameters = { "encoding" => "UTF-8", "indent" => "yes"}
    #outputoptions = { "encoding" => "UTF-8", "indent" => "yes"}
    connect
  end

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
  
  def createcollection(_name, _parent = nil)
    if (_parent == nil)
      begin
        result = @client.call("createCollection", _name)
        return result
      end
    else
      begin
        colname = _parent.getname + _name
        result = @client.call("createCollection", colname)
        return result
      end
    end
  rescue XMLRPC::FaultException => e
    raise e    
  rescue
    raise ExistException.new("Failed to create Collection", 2), caller
  end
  
  # TODO psat kolekci s lomitkem na konci
  def getcollection(path)
    col = Collection.new(@client, path)
    return col
  rescue  => e
    raise e  
  end
  
  def existscollection?(orig_path)
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

  def remove_collection(_name)
    # boolean removeCollection( String collection)
    result = @client.call("removeCollection", _name)
    return result
  rescue XMLRPC::FaultException => e
    raise e    
  rescue
    raise ExistException.new("Failed to remove Collection", 3), caller
  end
  
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
  
  #<email type="office">andrew@gmail.com</email>, pos = into | following | preceding, exprSingle e.g. //address[fname="Andrew"]
  def update_insert(expr, pos, exprSingle) 
    query = "update insert "+expr+" "+pos+" "+exprSingle
    #puts "query #{query}"
    execute_query(query)
  rescue  => e
    raise e    
  end
  
  def update_replace(expr, exprSingle)
    query = "update replace "+expr+" with "+exprSingle
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  def update_value(expr, exprSingle)
    query = "update replace "+expr+" with "+exprSingle
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  def update_delete(expr)
    query = "update delete "+expr
    #puts "query #{query}"
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  def update_rename(expr, exprSingle)
    query = expr + " as " + exprSingle
    execute_query(query)
  rescue  => e
    raise e  
  end

end


#db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
#puts db.existscollection?("db")

#client = XMLRPC::Client.new("localhost", "/exist/xmlrpc", 8080)

#-----------------
#if $*.length < 1 then
#  puts "usage: collections.rb collection-path"
#  exit(0)
#end
#
#path = $*[0]
#collection = Collection.new(client, "/db/pokus/")
#puts collection.to_s
#collection.documents { |d| puts d.to_s }
#
#doc = collection['books.xml']
#if doc == nil 
#  error("document not found")
#end
#puts doc.content