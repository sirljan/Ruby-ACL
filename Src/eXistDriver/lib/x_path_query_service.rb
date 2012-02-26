# To change this template, choose Tools | Templates
# and open the template in the editor.


require "collection"
require 'xmlrpc/client'
require 'rexml/document'


class XPathQueryService
  private
    @collection
    @parameters

  public
  def initialize(_col)
    @collection = _col.getserver
    @parameters = nil
  end

  
  def query(_query, _count = 0,  _start = 1)
    result = @collection.call("query",_query.to_s, _count.to_i ,_start.to_i, @parameters)
    doc = REXML::Document.new(result)

    return doc

  rescue
    begin
      raise ExistException.new("Failed to execute query", 20), "Failed to execute query", caller
    end
  end


  def queryresource(_docname,_query, _count = 0,  _start = 1)
    #upravime dotaz, aby se ptal na konkretni dokument
    q = "doc(\"" + _docname.to_s + "\")"+ _query.to_s
    result = @collection.call("query",q.to_s, _count.to_i ,_start.to_i, @parameters)
    doc = REXML::Document.new(result)
    return doc

    rescue
    begin
      raise ExistException.new("Failed to query resource", 21), "Failed to query resource", caller
    end
  end

  def parameters
    @parameters
  end

  def parameters=(newparams)
    @parameters = newparams
  end
end
