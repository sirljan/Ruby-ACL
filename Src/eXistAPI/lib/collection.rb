require "xmlrpc/client"
require 'document'

class Collection

  attr_reader :name
  attr_reader :owner
  attr_reader :group
  attr_reader :permissions
  attr_reader :childCollection
    
  #Creates new collection.
  #
  # * *Args*    :
  #   - +client+ -> e.g. ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")    
  #   - +collectionName+ -> /db/data/cities/
  # * *Returns* :
  #   -new instance of collection
  # * *Raises* :
  #   - +nothing+ ->
  #
  def initialize(client, collectionName)
    @client = client
    load(collectionName)
  rescue  => e
    raise e  
  end

  #Returns string of collection. That inclunde permissions, owner, group and name.
  #
  # * *Args*    :
  #   - +none+
  # * *Returns* :
  #   -string of collection
  # * *Raises* :
  #   - +nothing+
  #
  def to_s()
    return "#{@permissions} #{@owner} #{@group} #{@name}"
  end

  #Yield each document from collection.
  #
  # * *Args*    :
  #   - +none+
  # * *Returns* :
  #   -documents
  # * *Raises* :
  #   - +nothing+
  #
  def documents
    @documents.each { |d| yield d }
  end
  
  #Returns string array of all documents in collection
  #
  # * *Args*    :
  #   - +none+
  # * *Returns* :
  #   -array of strings
  # * *Raises* :
  #   - +nothing+
  #
  def docs    
    ds = []
    @documents.each{ |d| ds.push(d.name)}
    return ds
  end

  #Returns instance of collection's child specified by name.
  #
  # * *Args*    :
  #   - +key+ -> name of the child
  # * *Returns* :
  #   -instance of collection's child (document or collection)
  # * *Raises* :
  #   - +nothing+
  #
  def [](key)
    @documents.each { |d|
      return d if key == d.name 
    }
    return nil
  end

  protected
  
  #Loads collection from db.
  #
  # * *Args*    :
  #   - +collectionName+ -> e.g. /db/data/cities/
  # * *Returns* :
  #   - instance of collection
  # * *Raises* :
  #   - +ExistException+ -> Failed to load Collection
  #
  def load(collectionName)
    resp = @client.call("getCollectionDesc", collectionName)
    @name = resp['name']+"/"
    @owner = resp['owner']
    @group = resp['group']
    @permissions = resp['permissions']
    @childCollection = resp['collections']
            
    @documents = Array.new
    docs = resp['documents']
    #puts "docs #{docs}"
    docs.each { |d| @documents.push(Document.new(@client, d, @name)) }
  rescue XMLRPC::FaultException => e
    raise e
  rescue
    raise ExistException.new("Failed to load Collection", 10), callers
  end #end def load
end #end class Collection