require "xmlrpc/client"
require 'document'

class Collection

  attr_reader :name
  attr_reader :owner
  attr_reader :group
  attr_reader :permissions
  #attr_reader :documents
  attr_reader :childCollection
    
  def initialize(client, collectionName)
    @client = client
    load(collectionName)
  end

  def to_s()
    return "#{@permissions} #{@owner} #{@group} #{@name}"
  end

  def documents
    @documents.each { |d| yield d }
  end
  
  def docs    #returns string array of all documents in collection
    ds = []
    @documents.each{ |d| ds.push(d.name)}
    return ds
  end

  def [](key)
    @documents.each { |d|
      return d if key == d.name 
    }
    return nil
  end

  protected

  def load(collectionName)
    begin
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
      puts e
    end
  end
end