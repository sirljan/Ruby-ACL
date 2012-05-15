require 'document'

class Collection
  
  #name of the collection
  attr_reader :name
  #owner of the collection
  attr_reader :owner
  #owner group of the collection
  attr_reader :group
  #permissions of the collection
  attr_reader :permissions
  #descendent collection of the collection
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
    raise "Must be implemented."
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
  def docs    #returns string array of all documents in collection
    raise "Must be implemented."
    return array_of_documents
  end
end
