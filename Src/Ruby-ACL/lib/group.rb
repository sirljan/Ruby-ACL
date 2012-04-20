class Group < Principal
  
  def initialize(connector, col_path)
    super(connector, col_path)
  end
  
  private
  
  public
  
  def create_new(name, groups, members)
    super(name, groups)
    if(members.length > 0)
      for each in members
        add_membership(each, [name], true)
      end
    end
  rescue => e
    raise e
  end
  
end