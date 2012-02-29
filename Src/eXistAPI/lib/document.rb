class Document

  attr_reader :path
  attr_reader :name
  attr_reader :owner
  attr_reader :group
  attr_reader :permissions

  def initialize(client, hash, colname)
    @client = client
    @path = colname + hash['name']
    @name = @path[/[^\/]+$/]
    @owner = hash['owner']
    @group = hash['group']
    @permissions = hash['permissions']
  end

  def to_s
    return "#{@permissions} #{@owner} #{@group} #{@name}"
  end

  def content
    begin 
      options = { "indent" => "yes", "encoding" => "UTF-8",
        "expand-xincludes" => "yes" }
      return @client.call("getDocument", @path, options)
    rescue XMLRPC::FaultException => e
      error(e)
    end
  end
end