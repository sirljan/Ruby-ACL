class ResourceObject < ACL_Object
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}ResourceObjects.xml\")"
  end
  
  private
  def generate_expr(id, type, address, owner)
    expr = <<END
    <#{self.class.name} id="#{id}">
      <type>#{type}</type>
      <address>#{address}</address>
      <owner idref="#{owner}" />
    </#{self.class.name}>
END
    return expr
  end
  
  public
  def create_new(type, address, owner)
    id = find_res_ob(type, address)
    if(id == nil) #this resOb doesnt exist
      id = "r" + Random.rand(1000000000).to_s
      while(exists?(id))
        id = "r" + Random.rand(1000000000).to_s
      end
      expr = generate_expr(id, type, address, owner)
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
  
  def find_res_ob(type, address)    #finds resource object's id by type and address
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
      raise RubyACLException.new(self.class.name, __method__, "#{self.class.name}(type=\"#{type}\", address=\"#{address}\") exists more then once. (#{hits} times)", 32), caller
        #"#{self.class.name}(type=\"#{type}\", address=\"#{address}\") exists more then once. (#{hits} times)", caller
      #raise RubyACLException.new("neco se podelalo", 32), "neco se podelalo2", caller
      #return nil
    end
  end  
  
  def ge(temp_ace, final_ace, grid)
    temp = grid.find_index(temp_ace.res_obj)
    final = grid.find_index(final_ace.res_obj)
    return super(temp, final)
  end
  
  def change_owner(type, address, new_owner)
    res_ob_id = find_res_ob(type, address)
    
    query = "update value doc(\"#{@doc}\")/ResourceObjects/ResourceObject[#{res_ob_id}]/owner with \"#{new_owner}\""
    @connector.execute_query(query)
    query = "doc(\"#{@col_path}acl.xml\")/acl/string(@aclname)"
    handle = @connector.execute_query(query)
    if(new_owner != @connector.retrieve(handle, 0))
      raise RubyACLException.new("Failed to set new owner.", 51), 
        "Failed to set new owner.", caller
    end
  end
end