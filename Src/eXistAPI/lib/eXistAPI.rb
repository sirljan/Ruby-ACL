require "xmlrpc/client"
$:.unshift(".")
require 'collection'

class ExistAPI
  #example ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")    
  def initialize(uri = nil , username = nil, password = nil)
    @uri = uri
    @username = username
    @password = password
    @parameters = { "encoding" => "UTF-8", "indent" => "yes"}
    #outputoptions = { "encoding" => "UTF-8", "indent" => "yes"}
    connect
  end

  private
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
  
  def getcollection(path)
    path = check_slashes(path)
    col = Collection.new(@client, path)
    return col
  rescue  => e
    raise e  
  end
  
  def existscollection?(orig_path)
    #TODO puts db.existscollection?("db") vyhazuje chybu v irb pri testovani gemu
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
  
  #<email type="office">andrew@gmail.com</email>, pos = into | following | preceding, expr_single e.g. //address[fname="Andrew"]
  def update_insert(expr, pos, expr_single) 
    query = "update insert "+expr+" "+pos+" "+expr_single
    #puts "query #{query}"
    execute_query(query)
  rescue  => e
    raise e    
  end
  
  def update_replace(expr, expr_single)
    query = "update replace "+expr+" with "+expr_single
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  def update_value(expr, expr_single)
    query = "update replace " + expr + " with " + expr_single
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  def update_delete(expr)
    query = "update delete " + expr
    #puts "query #{query}"
    execute_query(query)
  rescue  => e
    raise e  
  end
  
  def update_rename(expr, expr_single)
    query = "update rename " + expr + " as " + expr_single
    #puts "query #{query}"
    execute_query(query)
  rescue  => e
    raise e  
  end
end


#db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
#puts db.existscollection?("db")
