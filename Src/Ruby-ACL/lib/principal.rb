class Principal < ACL_Object
  def initialize(connector, col_path, report = false)
    super(connector, col_path, report)
    @doc = "doc(\"#{@col_path}Principals.xml\")"
  end
  
  def eq (temp_ace, final_ace)
    if(temp_ace.prin == final_ace.prin)
      return true
    else 
      return false
    end
  end
  
  def ne (temp_ace, final_ace)
    return !eq(temp_ace, final_ace)
  end
  
  def delete(name)
    super(name)
    
    expr = "#{@doc}//node()[@idref=\"#{name}\"]/parent::node()"
    @connector.update_delete(expr)
    return name
  rescue => e
    raise e
  end
  
  def add_membership(name, groups, ob_exists = false)
    ok = true
    #Make sure that group is really group and not individual
    for group in groups
      if(!exists?(group, "#{@doc}//Group[@id=\"#{group}\"]"))
        ok = false;
      end
    end
    if(ok)
      super(name, groups, ob_exists)
    else
      raise RubyACLException.new(self.class.name, __method__, 
        "Failed to add membership. Group \"#{group}\" does not exist.", 113), caller
    end
  end
end
