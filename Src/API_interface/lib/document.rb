
class Document
  
  attr_reader :path
  attr_reader :name
  attr_reader :owner
  attr_reader :group
  attr_reader :permissions
  
  def initialize(client, hash, colname)
    raise "Must be implemented."    
  end
  
  def content
    raise "Must be implemented."    
  end
end
