require "exist_exception"
require "collection"
require 'rexml/document'
require 'xmlrpc/client'

class DatabaseManager
  @uri
  @username
  @password
  @server

  #
  def initialize(_uri = nil , _username = nil, _password = nil)
    @uri = _uri
    @username = _username
    @password = _password
    @parameters = { "encoding" => "UTF-8", "indent" => "yes"}
    connect
  end

  #
  def connect
    @server = XMLRPC::Client.new2(@uri)
    @server.user=(@username)
    @server.password=(@password)
    #tohle tady slouzi jako test, zda se pripojeni zdarilo
    @server.call("isXACMLEnabled")
  rescue
    begin
      raise ExistException.new("Database login failed", 1), "Database login failed", caller
    end
  end


  #
  def createcollection(_name, _parent = nil)
    if (_parent == nil)
      begin
        result = @server.call("createCollection", _name)
        return result
      end
    else
      begin
        colname = _parent.getname + _name
        result = @server.call("createCollection", colname)
        return result
      end
    end
  rescue
    begin
      raise ExistException.new("Failed to create Collection", 2), "Failed to create Collection", caller
    end
  end

  # psat kolekci s lomitkem na konci
  def getcollection(_path)
    col = Collection.new(@server, _path, @uri.to_s + _path.to_s)
    return col
  end

  #
  def removecollection(_name)
    # boolean removeCollection( String collection)
    result = @server.call("removeCollection", _name)
    return result
  rescue
    begin
      raise ExistException.new("Failed to remove Collection", 3), "Failed to remove Collection", caller
    end
  end
  
  def execute_query(xquery, parameters = @parameters)
    begin
      handle = @server.call("executeQuery", xquery, parameters)
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
