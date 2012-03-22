class Principal
  
  def initialize(name, connector, groups = [])
    @name = name
    @groups = groups
    expr = generate_expr()
    connector.update_insert(expr, "following", "/Principals/Individuals/principal[last()]")
  end
  
  attr_reader :name, :groups
  
  private  
  def generate_expr()
    expr = <<END
    <principal id="#{@name}">
      <membership>
        
      </membership>
    </principal>
END
    return expr
  end
  
  def Principal.exists?(name, connector, query = "/Principals/descendant::*[@id=\"#{name}\"]")
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
  
  def to_s
    return "#{id} \t #{name} \t #{groups}"
  end
    
  def add_membership(groups)

  end
  
  def change_name(new_name)
    @name = new_name
  end
  
  
end

