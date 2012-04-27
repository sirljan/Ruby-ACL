require 'document'

class Collection
  
  attr_reader :name
  attr_reader :owner
  attr_reader :group
  attr_reader :permissions
  attr_reader :childCollection
  
  def initialize(client, collectionName)
    raise "Must be implemented."
  end
  
  def docs    #returns string array of all documents in collection
    raise "Must be implemented."
    return array_of_documents
  end
end
