class Group < Principal
  
  def initialize(connector, col_path, report = false)
    super(connector, col_path, report)
  end
  
  private
  
  public
  
  def create_new(name, groups, members)
    super(name, groups)
    if(members.length > 0)    #add members into group
      for member in members
        add_membership(member, [name])
      end
    end
  rescue => e
    raise e
  end
  
  def delete(name)
    super(name)
    
    expr = "#{@doc}//node()[@idref=\"#{name}\"]"
    @connector.update_delete(expr)
    return name
  rescue => e
    raise e
  end
  
end