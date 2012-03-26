class Privilege
  
  attr_reader :access_type
  attr_reader :name
  
  def initialize(name, connector)
    super(name, connector)
  end
  
end