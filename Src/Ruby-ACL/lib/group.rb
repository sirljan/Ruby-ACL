class Group < ACL_Object
  
  attr_reader :name
  
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}Principals.xml\")/Principals"
  end
  
  private
  
  public
  
  def create_new(name, groups = [], members = [])
    super(name, groups)
    if(members.length > 0)
      for each in members
        add_membership(each, [name], true)
      end
    end
  end
  
end