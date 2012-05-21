class Document

  #path of the document
  attr_reader :path
  #name of the document
  attr_reader :name
  #owner of the document
  attr_reader :owner
  #owner group of the document
  attr_reader :group
  #permissions of the document
  attr_reader :permissions
  
  #Creates new instance of document
  #
  # * *Args*    :
  #   - +client+ -> e.g. ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")    
  #   - +hash+ -> hash, name -> "name of the document"
  #   - +colname+ -> name of the collection
  # * *Returns* :
  #   -instance of document
  # * *Raises* :
  #   - +nothing+
  # * *Example* :
  #   - Document.new(api, hash, collection_path)
  def initialize(client, hash, colname)
    @client = client
    @path = colname + hash['name']
    @name = @path[/[^\/]+$/]
    #puts "filename #{@name}"
    @owner = hash['owner']
    @group = hash['group']
    @permissions = hash['permissions']
  rescue  => e
    raise e  
  end
  
  #Returns string of document. That inclunde permissions, owner, group and name.
  #
  # * *Args*    :
  #   - +none+
  # * *Returns* :
  #   -string of collection
  # * *Raises* :
  #   - +nothing+
  #
  def to_s
    return "#{@permissions} #{@owner} #{@group} #{@name}"
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
    options = { "indent" => "yes", "encoding" => "UTF-8",
      "expand-xincludes" => "yes" }
    return @client.call("getDocument", @path, options)
  rescue XMLRPC::FaultException => e
    raise e
  rescue
    raise ExistException.new("Failed to load content of Document", 11), callers
  end
end