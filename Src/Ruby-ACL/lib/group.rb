class Group < ACL_Object
  
  attr_reader :name
  
  def initialize(name, connector, groups = [], members = [])
    super(name, connector, groups)    
    if(members.length > 0)
      for each in members
        add_membership(each, [name], true)
      end
    end
  end
  
  private
  
  public
  
end