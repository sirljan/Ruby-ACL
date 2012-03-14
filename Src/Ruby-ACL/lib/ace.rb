class Ace
  @@ace_counter = 0
  def initialize(prin_name, acc_type, priv_name, res_ob_id, connector)
    @id = @@ace_counter
    @prin_id = prin_name
    @acc_type = acc_type
    @priv_id = priv_name
    @res_ob_id = res_ob_id
    @@ace_counter += 1
    expr = generate_expr()
    connector.update_insert(expr, "following", "/acl/ACEs/ace[last()]")
  end
  
  attr_reader :id, :prin_id, :priv_id, :res_ob_id
  
  private
  def generate_expr()
    expr = <<END
    <ace id="#{@id}">
      <principal idref="#{@prin_id}"/>
      <accessType>#{@acc_type}</accessType>
      <privilege idref="#{@priv_id}"/>
      <resourceObject idref="#{@res_ob_id}"/>
    </ace>
END
    return expr
  end
  def Ace.exists?(name, connector, query = "/acl/ACEs/descendant::*[@id=\"#{name}\"]")
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
    
  def Ace.ace_counter
    @@ace_counter
  end
  
  def to_s
    "#{principal.id} \t #{principal.name} \t #{privilege.access_type} \t #{privilege.operation} \t #{resource_object.name}"
  end
  
end