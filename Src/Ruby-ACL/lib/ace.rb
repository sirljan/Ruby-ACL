class Ace < ACL_Object
  
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}acl.xml\")"
  end
  
  private
  def generate_expr(id, prin_id, acc_type, priv_id, res_ob_id)
    expr = <<END
    <ace id="a#{id}">
      <principal idref="#{prin_id}"/>
      <accessType>#{acc_type}</accessType>
      <privilege idref="#{priv_id}"/>
      <resourceObject idref="#{res_ob_id}"/>
    </ace>
END
    return expr
  end
  
  protected
  
  public
  def create_new(prin_id, acc_type, priv_id, res_ob_id)
    id = "a" + Random.rand(1000000000).to_s
    while(exists?(id))
      id = "a" + Random.rand(1000000000).to_s
    end
    expr = generate_expr(prin_id, acc_type, priv_id, res_ob_id)
    expr_loc = "#{@doc}//#{self.class.name}s/#{self.class.name}[last()]"
    #puts expr_loc
    @connector.update_insert(expr, "following", expr_loc)
    if(exists?(id))
      #puts "New #{self.class.name} \"#{name}\" created."
      return id
    else
      puts "#{self.class.name} \"#{id}\" was not able to create."
      return nil
    end
    
  end
end