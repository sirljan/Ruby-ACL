class Privilege
  def initialize(name, connector)
    @operation = name
    @connector = connector
    expr = generate_expr()
    #puts expr
    connector.update_insert(expr, "following", "/Privileges/privilege[last()]")
  end
  
  attr_reader :access_type, :name
  
  private
    
  def generate_expr()
    expr = <<END
    <privilege id="#{@operation}">
      <membership>
        
      </membership>
    </privilege>
END
    return expr
  end
  
  def Privilege.exists?(name, connector, query = "/Privileges/descendant::*[@id=\"#{name}\"]")
    #puts "principal.exists?"
    #puts "guery #{query}"
    handle = connector.execute_query(query)
    hits = connector.get_hits(handle)
    #puts "hits #{hits}"
    if(hits >= 1)
      return true
    else 
      return false
    end
  end
  
  public
  
  def Privilege.default_privileges
    puts "Not supported yet."
  end
  
  def to_s
    return "#{access_type} \t #{operation}"    
  end
  
end