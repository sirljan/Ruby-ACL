class ResourceObject < ACL_Object
  def initialize(connector, col_path, report = false)
    super(connector, col_path, report)
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
    
  def parent(adr)
    if(adr[-1] == "/")    #if last is "/" then delete it
      adr = adr[0..-2]
    end
    pos = adr.rindex("/")
    adr = adr[0..pos-1]
    return adr
  end
  
  def get_adr(res_ob_id)
    query = "#{@doc}//node()[@id=\"#{res_ob_id}\"]/address/text()"
    #puts query
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    if(hits == 1)
      adr = @connector.retrieve(handle, 0)
    else
      raise RubyACLException.new(self.class.name, __method__, 
        "#{self.class.name}(id=\"#{res_ob_id}\") exists more then once. (#{hits}x)", 31), caller
    end
    return adr
  rescue => e
    raise e
  end
  
  def get_type(res_ob_id)
    query = "#{@doc}//node()[@id=\"#{res_ob_id}\"]/type/text()"
    #puts query
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    if(hits == 1)
      type = @connector.retrieve(handle, 0)
    else
      raise RubyACLException.new(self.class.name, __method__, 
        "#{self.class.name}(id=\"#{res_ob_id}\") exists more then once. (#{hits}x)", 32), caller
    end
    return type
  rescue => e
    raise e
  end
  
  def change(type, address, what_is_changed, with_what)
    address.delete!('(")')
#    puts "type ,#{type},"
#    puts "adr ,#{address},"
    res_ob_id = find_res_ob(type, address)
    if(res_ob_id.nil?)
      raise RubyACLException.new(self.class.name, __method__, 
        "Failed to change #{what_is_changed}. Resource objects doesn't exist.", 36), caller
    end
    if(what_is_changed == "owner")
      expr = "#{@doc}//node()[@id=\"#{res_ob_id}\"]/#{what_is_changed}/@idref"
    else
      expr = "#{@doc}//node()[@id=\"#{res_ob_id}\"]/#{what_is_changed}/text()"  
    end
    expr_single = "\"#{with_what}\""
    @connector.update_value(expr, expr_single)
    if(what_is_changed == "type")
      res_ob_id = find_res_ob(with_what, address)
    end
    if (what_is_changed == "address")
      res_ob_id = find_res_ob(type, with_what)
    end
    if(what_is_changed == "owner")
      expr = "#{@doc}//node()[@id=\"#{res_ob_id}\"]/#{what_is_changed}/string(@idref)"
    end
    handle = @connector.execute_query(expr)
    hits = @connector.get_hits(handle)
    if(hits == 1)
      res = @connector.retrieve(handle, 0)
      if(with_what == res)
        puts "Change #{what_is_changed} succeeded." if @report
      else
        raise RubyACLException.new(self.class.name, __method__, 
          "Failed to change #{what_is_changed}.", 34), caller
      end
    else
      raise RubyACLException.new(self.class.name, __method__, 
        "Failed to change #{what_is_changed}.", 34), caller
    end
  rescue => e
    raise e
  end
  
  public
  def create_new(type, address, owner)
    address.delete!('(")')
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
        puts "New #{self.class.name} \"#{id}\" created." if @report
        return id
      else
        raise RubyACLException.new(self.class.name, __method__, 
          "#{self.class.name} type=\"#{type}\", address=\"#{address}\" was not able to create.", 33), caller
      end
    else #already exists
      puts "#{self.class.name} \"#{id}\" was already created created." if @report
      return id
    end
  end
  
  def find_res_ob(type, address)    #finds resource object's id by type and address
    address.delete!('(")')
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
      raise RubyACLException.new(self.class.name, __method__, 
        "#{self.class.name}(type=\"#{type}\", address=\"#{address}\") exists more then once. (#{hits}x)", 30), caller
    end
  end  
  
  def ge(temp_ace, final_ace, grid)
    temp = grid.find_index(temp_ace.res_obj)
    final = grid.find_index(final_ace.res_obj)
    return super(temp, final)
  end
  
  #finds membership parrent, e.g. dog's parrent is mammal
  def find_res_ob_parents(res_ob_type, res_ob_adr)   
    ids = Array.new    
    while(res_ob_adr.rindex("/") != 0)
      res_ob_adr = parent(res_ob_adr)
      #puts res_ob_adr 
      ids.push(find_res_ob(res_ob_type, res_ob_adr))      
    end
    #puts "ids #{ids.to_s}"
    ids.compact!
    #puts "ids #{ids.to_s}"
    return ids
  rescue => e
    raise e
  end
  
  #finds resOb, which ends with /*
  def res_obs_grand2children(res_ob_ids)
    ids = Array.new    
    for res_ob_id in res_ob_ids
      adr = get_adr(res_ob_id)
      type = get_type(res_ob_id)
      adr += "/*"  
      ids.push(find_res_ob(type, adr))      
    end
    ids.compact!
    return ids
  rescue => e
    raise e
  end
  
  def rename()
    raise RubyACLException.new(self.class.name, __method__, 
      "Rename method is not supported for resource object", 35), caller
  end
  
  def change_type(type, address, new_type)
    change(type, address, "type", new_type)
  end
  
  def change_address(type, address, new_address)
    change(type, address, "address", new_address)
  end
  
  def change_owner(type, address, new_owner)
    change(type, address, "owner", new_owner)
  end
  
end #class ResourceObject