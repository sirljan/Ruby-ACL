class ResourceObject < ACL_Object
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}ResourceObjects.xml\")"
  end
  
  private
  def generate_expr(id, type, address)
    expr = <<END
    <#{self.class.name} id="#{id}">
      <type>#{type}</type>
      <address>#{address}</address>
    </#{self.class.name}>
END
    return expr
  end
  
  public
  def create_new(type, address)
    id = find_res_ob(type, address)
    if(id == nil) #this resOb doesnt exist
      id = "r" + Random.rand(1000000000).to_s
      while(exists?(id))
        id = "r" + Random.rand(1000000000).to_s
      end
      expr = generate_expr(id, type, address)
      expr_loc = "#{@doc}//#{self.class.name}s/#{self.class.name}[last()]"
      #puts expr_loc
      @connector.update_insert(expr, "following", expr_loc)
      if(exists?(id))
        #puts "New #{self.class.name} \"#{name}\" created."
        return id
      else
        #puts "#{self.class.name} \"#{id}\" was not able to create."
        raise RubyACLException.new("#{self.class.name} type=\"#{type}\", address=\"#{address}\" was not able to create.", 33), 
          "#{self.class.name} type=\"#{type}\", address=\"#{address}\" was not able to create.", caller
      end
    else #already exists
      return id
    end
  end
  
  def find_res_ob(type, address)
    query = "#{@doc}//#{self.class.name}s/descendant::*[type=\"#{type}\" and address=\"#{address}\"]/string(@id)"
    #puts query
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    #puts hits
    case hits
    when 1
      res_ob_id = @connector.retrieve(handle, 0)
      if(res_ob_id == "")   #eXist returns empty result => should return no result
        return nil
      else
        return res_ob_id
      end
      
    when 0
      return nil
    else
      raise RubyACLExceptionRubyACLException.new("#{self.class.name} type=\"#{type}\", address=\"#{address}\" exists more then once.", 32), 
        "#{self.class.name} type=\"#{type}\", address=\"#{address}\" exists more then once. (#{hits} times)", caller
      #return nil
    end
  end

end