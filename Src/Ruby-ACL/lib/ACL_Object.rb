
class ACL_Object
  
  attr_reader :doc
  attr_reader :col_path
  
  def initialize(connector, col_path)#TODO, report = false)
    @connector = connector
    @col_path = col_path
  end
  
  private  #--------------PRIVATE-----------------------------------------------
  
  def generate_expr(name)
    expr = <<END
    <#{self.class.name} id="#{name}">
      <membership>
        
      </membership>
    </#{self.class.name}>
END
    return expr
  rescue => e
    raise e
  end
  
  def exists?(name, query = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]")
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    if(hits >= 1)
      return true
    else 
      return false
    end
  rescue => e
    raise e
  end
  
  def exist_membership?(name, member_of)        #Is <name> member of <member_of>
    expr = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]/membership/mgroup[@idref=\"#{member_of}\"]"
    exists?(name, expr)
  rescue => e
    raise e
  end
  
  public #------------------PUBLIC----------------------------------------------
  
  def to_s #TODO
    #return "#{id} \t #{name} \t #{groups}"
  rescue => e
    raise e
  end
  
  def create_new(name, groups)
    bool=true
    if(name == nil || name == '')
      puts "Name is empty."
      bool = false
      raise RubyACLException.new(self.class.name, __method__, 
        "Name is empty", 10), caller
    end
    if(exists?(name))
      puts "#{self.class.name} \"#{name}\" already exist. Please choose different name."
      bool = false
      raise RubyACLException.new(self.class.name, __method__, 
        "#{self.class.name} \"#{name}\" already exist(s)", 11), caller
    end
  
    if(bool)
      expr = generate_expr(name)
      expr_loc = "#{@doc}//#{self.class.name}s/#{self.class.name}[last()]"
      @connector.update_insert(expr, "following", expr_loc)
      if(exists?(name))
        #TODO puts "New #{self.class.name} \"#{name}\" created." if @report
      else
        puts "#{self.class.name} \"#{name}\" was not able to create."
        raise RubyACLException.new(self.class.name, __method__, 
          "#{self.class.name} \"#{name}\" was not able to create", 12), caller
      end
    end
    if(groups.length > 0)
      add_membership(name, groups, true)
    end
  rescue XMLRPC::FaultException => e
    raise e    
  rescue => e
    raise e
  end
    
  #adds acl object into group(s); if you know prin exists set true for prin_exists
  def add_membership(name, groups, ob_exists = false) 
    #protection against cycle in membership
    
    if(ob_exists || exists?(name))
      for group in groups
        if(!exists?(group))
          raise RubyACLException.new(self.class.name, __method__, 
            "Failed to add membership. Group \"#{group}\" does not exist.", 13), caller
        end        
        asdf=[]
        asdf.fin
        if(find_parents(group).find_index(name).nil?)
          expr = "<mgroup idref=\"#{group}\"/>"
          expr_single = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]/membership"
          @connector.update_insert(expr, "into", expr_single)
        else
          raise RubyACLException.new(self.class.name, __method__, 
        "Failed to add membership. Membership is in cycle.", 18), caller
        end
      end
    else
      raise RubyACLException.new(self.class.name, __method__, 
        "Failed to add membership. #{self.class.name} \"#{name}\" does not exist.", 14), caller
    end
  rescue => e
    raise e
  end #def add_membership
  
  def del_membership(name, groups) #deletes prin_name from group(s)
    if(exists?(name))
      for group in groups
        expr = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]/membership/mgroup[@idref=\"#{group}\"]"
        @connector.update_delete(expr)
        #end
        if(!exists?(group))
          raise RubyACLException.new(self.class.name, __method__, 
            "Failed to delete membership. Group \"#{group}\" does not exist.", 15), caller
        end
      end
    else
      puts "#{self.class.name} with name \"#{name}\" does not exist."
      raise RubyACLException.new(self.class.name, __method__,
        "Failed to delete membership. #{self.class.name} \"#{name}\" does not exist.", 16), caller
    end
  rescue => e
    raise e
  end #def del_membership
  
  def delete(name)
    if(exists?(name))
      expr = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]"
      @connector.update_delete(expr)
    else
      puts "WARNING: #{self.class.name} \"#{name}\" does not exist."
      raise RubyACLException.new(self.class.name, __method__,
        "Failed to delete #{self.class.name}. #{self.class.name} \"#{name}\" does not exist.", 17), caller
    end
    return name
  rescue => e
    raise e
  end #def delete
  
  def rename(old_name, new_name)
    #TODO rename
  end
  
  def ge(t, f)
    if(t >= f)
      return true
    else
      return false
    end
  end
  
  #finds membership parrent and returns in sorted array by level, 
  #Root is first leaf is last.
  #e.g. dog's parrent is mammal.
  def find_parents(id, doc)   
    query = "#{doc}//node()[@id=\"#{id}\"]/membership/*/string(@idref)"
    ids = []
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    hits.times {
      |i|
      id_ref = @connector.retrieve(handle, i)
      if(id_ref=="")
        next      #for unknown reason eXist returns 1 empty hit even any exists therefore unite is skipped (e.g. //node()[@id="all"]/membership/*/string(@idref)
      end
      ids = find_parent(id_ref, doc) | ids | [id_ref]    #unite arrays
    }
    return ids
  rescue => e
    raise e
  end
  
end
