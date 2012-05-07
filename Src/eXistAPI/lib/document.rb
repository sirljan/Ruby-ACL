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