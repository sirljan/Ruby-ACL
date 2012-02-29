class Principal
  #@@prin_counter = 0
  
  def initialize(name, groups = [], connector)
    #@id = @@prin_counter
    @name = name
    @groups = groups
    #@@prin_counter += 1
    expr = generate_expr()
    connector.update_insert(expr, "following", "/acl/Principals/Individuals/principal[last()]")
  end
  
  attr_reader :id, :name, :groups
  
  private  
  def generate_expr()
    g = ''
    for each in groups
      g = g + "<group>#{each}</group>"
    end
    ##{g}
    expr = <<END
    <principal>
      <name>#{@name}</name>
      <membership>
        
      </membership>
    </principal>
END
    return expr
  end
  
  def Principal.exists?(name, connector, query = "/acl/Principals/Individuals/principal[name=\"#{name}\"]")
#    puts "principal.exists?"
#    puts "guery #{query}"
    handle = connector.execute_query(query)
    hits = connector.get_hits(handle)
#    puts "hits #{hits}"
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
  #private :add_membership, :change_name
  
end

