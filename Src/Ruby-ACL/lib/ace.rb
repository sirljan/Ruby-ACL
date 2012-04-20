class Ace < ACL_Object
  
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}acl.xml\")"
  end
  
  private
  def generate_expr(id, prin_id, acc_type, priv_id, res_ob_id)
    expr = <<END
    <Ace id="#{id}">
      <Principal idref="#{prin_id}"/>
      <accessType>#{acc_type}</accessType>
      <Privilege idref="#{priv_id}"/>
      <ResourceObject idref="#{res_ob_id}"/>
    </Ace>
END
    return expr
  end
  
  #finds ace's id by principal id, acc_type, privilege id, resource object id
  def find_ace(prin_id, acc_type, priv_id, res_ob_id)   
    query = "#{@doc}//#{self.class.name}s/descendant::*
[Principal/@idref=\"#{prin_id}\" and accessType=\"#{acc_type}\" and 
Privilege/@idref=\"#{priv_id}\" and ResourceObject/@idref=\"#{res_ob_id}\"]
/string(@id)"
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    case hits
    when 1
      ace_id = @connector.retrieve(handle, 0)
      if(ace_id == "")   #eXist returns empty result => should return no result
        return nil
      else
        return ace_id
      end
      
    when 0
      return nil
    else
      raise RubyACLExceptionRubyACLException.new(self.class.name, __method__,
        "#{self.class.name} 
Principal=\"#{prin_id}\" and accessType=\"#{acc_type}\" and 
Privilege=\"#{priv_id}\" and ResourceObject=\"#{res_ob_id}\" 
exists more then once. (#{hits}x)", 20), caller
    end
  rescue => e
    raise e
  end   #def find_ace
  
  protected
  
  public
  def create_new(prin_id, acc_type, priv_id, res_ob_id)
    id = find_ace(prin_id, acc_type, priv_id, res_ob_id)
    if(id == nil) #this ace doesnt exist
      id = "a" + Random.rand(1000000000).to_s
      while(exists?(id))
        id = "a" + Random.rand(1000000000).to_s
      end
      expr = generate_expr(id, prin_id, acc_type, priv_id, res_ob_id)
      expr_loc = "#{@doc}//#{self.class.name}s/#{self.class.name}[last()]"
      #puts expr_loc
      @connector.update_insert(expr, "following", expr_loc)
      if(exists?(id))
        #puts "New #{self.class.name} \"#{name}\" created."
        return id
      else
        puts "#{self.class.name} \"#{id}\" was not able to create."
        raise RubyACLException.new(self.class.name, __method__, 
          "#{self.class.name} \"#{id}\" was not able to create.", 21), caller
        return nil
      end
    else #already exists
      return id
    end
  rescue => e
    raise e
  end   #def create_new
end   #class Ace