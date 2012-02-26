require "xmlrpc/client"
require 'collection'

def error(s)
  puts s
end



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
    connect
  end

  #
  def connect
    @client = XMLRPC::Client.new2(@uri)
    @client.user=(@username)
    @client.password=(@password)
    #tohle tady slouzi jako test, zda se pripojeni zdarilo
    @client.call("isXACMLEnabled")
  rescue
    begin
      raise ExistException.new("Database login failed", 1), "Database login failed", caller
    end
  end


  #
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
  rescue
    begin
      raise ExistException.new("Failed to create Collection", 2), "Failed to create Collection", caller
    end
  end

  # psat kolekci s lomitkem na konci
  def getcollection(path)
    col = Collection.new(@client, path)
    return col
  end

  #
  def removecollection(_name)
    # boolean removeCollection( String collection)
    result = @client.call("removeCollection", _name)
    return result
  rescue
    begin
      raise ExistException.new("Failed to remove Collection", 3), "Failed to remove Collection", caller
    end
  end
  
  def storeresource(_res, _docname, _overwrite = 1)
    if ((_res == nil)||(_docname == nil))
      raise ExistException.new("Resource or document name is nil",18), "Resource or document name is nil", caller
    end
    begin
      @client.call("parse",_res.to_s, _docname, _overwrite)
    rescue XMLRPC::FaultException => e
      puts e
    end
  end
  
  def execute_query(xquery, parameters = @parameters)
    begin
      handle = @client.call("executeQuery", xquery, parameters)
      return handle
    rescue XMLRPC::FaultException => e
      #raise ExistException.new("Failed to execute Query", 4), "Failed to execute Query", caller
      puts "An error occurred:"
      puts e.faultCode
      puts e.faultString
    end
  end
  
  def update_insert(expr, pos, exprSingle) #<email type="office">andrew@gmail.com</email>, pos = into | following | preceding, exprSingle e.g. //address[fname="Andrew"]
    query = "update insert "+expr+" "+pos+" "+exprSingle
    execute_query(query)
  end
  
  def update_replace(expr, exprSingle)
    query = "update replace "+expr+" with "+exprSingle
    execute_query(query)
  end
  
  def update_value(expr, exprSingle)
    query = "update replace "+expr+" with "+exprSingle
    execute_query(query)
  end
  
  def update_delete(expr)
    query = expr
    execute_query(query)
  end
  
  def update_rename(expr, exprSingle)
    query = expr + " as " + exprSingle
    execute_query(query)
  end

end

#client = XMLRPC::Client.new("localhost", "/exist/xmlrpc", 8080)
#
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