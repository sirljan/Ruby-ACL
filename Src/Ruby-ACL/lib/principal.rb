class Principal < ACL_Object
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}Principals.xml\")"
  end
  
  def exists?(name)
    query = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]"
    super(name, query)
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
  
end
