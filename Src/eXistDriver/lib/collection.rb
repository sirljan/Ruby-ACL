require 'xmlrpc/client'
require "x_path_query_service"
require "x_path_update_service"
class Collection
  private
  @server
  # uri tzn cesta db
  @uri
  #  @password
  #  @user
  @services
  @parameters
  #cesta ke konkterni kolekci
  @path
   
  public
  #
  def initialize(_server,_path,_uri)
    @server = _server
    @path = _path
    @uri = _uri
    #test, zda kolekce existuje
    @server.call("getDocumentListing",@path)
    @parameters = nil
    registerservices
  rescue
    begin
      raise raise ExistException.new("Failed to initialize Collection", 10), "Failed to initialize Collection", caller
    end
  end
 
  def close
    @server.call("sync")
  rescue
    begin
      raise ExistException.new("Failed to close Collection",11), "Failed to close Collection", caller
    end
  end
  #deprecated
  #  def createid
  #    newid = @server.call("createResourceId", @path)
  #    return newid
  #
  #  rescue
  #    begin
  #      raise ExistException.new("Cant create new resource ID"), "Cant create new resource ID", caller
  #    end
  #  end
  #
  #
  def getchildcollection(_name)
    childs = self.listchildcollections
    for c in childs
      begin
        if (c == _name)
          col = Collection.new(@server, @path + _name + "/", @uri + _name + "/")
          return col
        end
      end
    end
    raise ExistException.new("No such child Collection",12), "No such child Collection", caller
  end
 
  #
  def getname
    @path
  end
  #
  def geturi
    @uri
  end
  #
  def getparentcollection
    parentpath = @path.chop
    ind = parentpath.rindex("/")
    parentpath = parentpath[0..ind]
    parenturi = @uri.chop
    ind = parenturi.rindex("/")
    parenturi = parenturi[0..ind]
    col = Collection.new(@server, parentpath, parenturi)
    return col
  rescue
    begin
      raise ExistException.new("Failed to get parent Collection", 13), "Failed to get parent Collection", caller
    end
  end
  # opet bere relativni cestu tzn @path
  #byte[] getDocument(String name, String encoding, int prettyPrint, String stylesheet)
  def getresource(_name)
    result = @server.call("getDocument", _name.to_s, @parameters)
    resxml = Document.new(result)
    return resxml
  rescue
    begin
      raise ExistException.new("Unknown resource",14), "Unknown resource", caller
    end
   
  end
  def getserver
    @server
  end
  def getservice(name)
    @services[name]
  end
  def getservices
    @services
  end
  #
  def listchildcollections
    desc = @server.call("describeResource", @path)
    return desc["collections"]
  rescue
    begin
      raise ExistException.new("Failed to list child Collections",15), "Failed to list child Collections", caller
    end
  end
  #
  def listresources
    resources = @server.call("getDocumentListing",@path)
    return resources
  rescue
    begin
      raise ExistException.new("Failed to list resources", 16), "Failed to list resources", caller
    end
  end
  #
  def registerservices
    @services = {"XPathQueryService" => XPathQueryService.new(self), "XUpdateQueryService" => XUpdateQueryService.new(self)}
  end
  #
  def removeresource(_name)
    result = @server.call("remove", _name)
    return result
  rescue
    begin
      raise ExistException.new("Failed to remove resource",17), "Failed to remove resource", caller
    end
  end
  # pozor v docname musi byt relativni cesta, ziskana pomoci collection.getname
  def storeresource(_res, _docname, _overwrite = 1)
    if ((_res == nil)||(_docname == nil))
      raise ExistException.new("Failed to store resource",18), "Failed to store resource", caller
    end
    @server.call("parse",_res.to_s, _docname, _overwrite)
  rescue
    begin
      raise ExistException.new("Failed to store resource",18), "Failed to store resource", caller
    end
  end
  
  def updateresource(_docname, _xupdate)
    begin
      #    puts "------------------------"
      #    puts "doc"
      #    puts _docname
      #    puts "xup"
      #    puts _xupdate.to_s
      #    if ((_xupdate == nil)||(_docname == nil))
      #      raise ExistException.new("Failed to update resource (_xupdate == nil)||(_docname == nil)",19), "Failed to update resource (_xupdate == nil)||(_docname == nil)", caller
      #    end    
      @server.call("xupdateResource", _docname, _xupdate.to_s)
    rescue XMLRPC::FaultException => e
      raise e
    end
  end
  
  def parameters
    @parameters
  end
  def parameters=(newparams)
    @parameters = newparams
  end
end