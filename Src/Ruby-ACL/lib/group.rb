class Group < Principal
  
  def initialize(connector, col_path)
    super(connector, col_path)
  end
  
  private
  
  public
  
  def create_new(name, groups, members)
    super(name, groups)
    if(members.length > 0)    #add members into group
      for member in members
        add_membership(member, [name], true)
      end
    end
  rescue => e
    raise e
  end
  
end