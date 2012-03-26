class Principal < ACL_Object
  
  attr_reader :name
  attr_reader :groups
  
  def initialize(name, connector, groups = [])
    super(name, connector, groups)
  end
end

