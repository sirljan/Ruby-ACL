require "xmlrpc/client"
require 'document'

class Collection

  attr_reader :name
  attr_reader :owner
  attr_reader :group
  attr_reader :permissions
    
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
      docs.each { |d| @documents.push(Document.new(@client, d, @name)) }
    rescue XMLRPC::FaultException => e
      puts e
    end
  end
end