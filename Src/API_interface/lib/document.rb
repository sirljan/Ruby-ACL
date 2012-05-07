
class Document
  
  attr_reader :path
  attr_reader :name
  attr_reader :owner
  attr_reader :group
  attr_reader :permissions
  
  #Creates new instance of document
  #
  # * *Args*    :
  #   - +client+ -> e.g. ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")    
  #   - +hash+ -> hash array of document in db that includes name, owner, group and permissions
  #   - +colname+ -> name of the collection
  # * *Returns* :
  #   -instance of document
  # * *Raises* :
  #   - +nothing+
  #
  def initialize(client, hash, colname)
    raise "Must be implemented."    
  end
  
  #Returns content of document in db. Usually document is xml.
  #Retrieves a document from the database.
  # * *Args*    :
  #   - +none+
  # * *Returns* :
  #   - the result of call
  # * *Raises* :
  #   - +ExistException+ -> Failed to load content of Document
  #
  def content
    raise "Must be implemented."    
  end
end
