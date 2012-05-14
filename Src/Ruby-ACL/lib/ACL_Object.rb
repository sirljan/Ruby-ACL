
class ACL_Object
  
  attr_reader :doc
  attr_reader :col_path
  
  def initialize(connector, col_path, report = false)
    @connector = connector
    @col_path = col_path
    @report = report
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
  
  def exists?(name, query = "#{@doc}//node()[@id=\"#{name}\"]")
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
  
  def create_new(name, groups)
    bool=true
    if(name == nil || name == '')
      bool = false
      raise RubyACLException.new(self.class.name, __method__, 
        "Name is empty", 110), caller
    end
    if(exists?(name))
      bool = false
      raise RubyACLException.new(self.class.name, __method__, 
        "#{self.class.name} \"#{name}\" already exist(s)", 111), caller
    end
  
    if(bool)
      expr = generate_expr(name)
      expr_loc = "#{@doc}//#{self.class.name}s/#{self.class.name}[last()]"
      @connector.update_insert(expr, "following", expr_loc)
      if(exists?(name))
        puts "New #{self.class.name} \"#{name}\" created." if @report
      else
        raise RubyACLException.new(self.class.name, __method__, 
          "#{self.class.name} \"#{name}\" was not able to create", 112), caller
      end
    end
    if(groups.length > 0)
      add_membership(name, groups, true)
    end
    return name
  rescue XMLRPC::FaultException => e
    raise e    
  rescue => e
    raise e
  end
    
  #adds acl object into group(s); if you know prin exists set true for prin_exists
  def add_membership(name, groups, ob_exists = false)   
    if(ob_exists || exists?(name))#, "#{@doc}//Individual[@id=\"#{name}\"]"))
      for group in groups
        if(!exists?(group))#, "#{@doc}//Group[@id=\"#{group}\"]"))
          raise RubyACLException.new(self.class.name, __method__, 
            "Failed to add membership. Group \"#{group}\" does not exist.", 113), caller
        end
        query = "#{@doc}//node()[@id=\"#{name}\"]/membership/mgroup[@idref=\"#{group}\"]"
        handle = @connector.execute_query(query)
        hits = @connector.get_hits(handle)
        if(hits == 0)
          #protection against cycle in membership
          if(find_parents(group).find_index(name).nil?) 
            expr = "<mgroup idref=\"#{group}\"/>"
            expr_single = "#{@doc}//node()[@id=\"#{name}\"]/membership"
            @connector.update_insert(expr, "into", expr_single)
          else
            raise RubyACLException.new(self.class.name, __method__, 
              "Failed to add membership. Membership is in cycle.", 118), caller
          end
        else
          puts "Membership already exists." if @report
        end
      end
    else
      raise RubyACLException.new(self.class.name, __method__, 
        "Failed to add membership. #{self.class.name} \"#{name}\" does not exist.", 114), caller
    end
    return name
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
            "Failed to delete membership. Group \"#{group}\" does not exist.", 115), caller
        end
      end
    else
      raise RubyACLException.new(self.class.name, __method__,
        "Failed to delete membership. #{self.class.name} \"#{name}\" does not exist.", 116), caller
    end
    return name
  rescue => e
    raise e
  end #def del_membership
  
  def delete(name)
    if(exists?(name))
      #deletes ACL_Object
      expr = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]"
      @connector.update_delete(expr)
      #deletes references at ACL_Object
      expr = "#{@doc}//node()[@idref=\"#{name}\"]"
      @connector.update_delete(expr)
      #deletes ACE mentioning ACL_Object
      expr = "doc(\"#{@col_path}acl.xml\")//node()[@idref=\"#{name}\"]/parent::node()"
      @connector.update_delete(expr)
    else
      raise RubyACLException.new(self.class.name, __method__,
        "Failed to delete #{self.class.name}. #{self.class.name} \"#{name}\" does not exist.", 117), caller
    end
    return name
  rescue => e
    raise e
  end #def delete
  
  def rename(old_name, new_name)
    if(!exists?(new_name))
      
      expr = "#{@doc}//node()[@id=\"#{old_name}\"]/@id"
      expr_single = "\"#{new_name}\""
      @connector.update_value(expr, expr_single)
      
      expr = "#{@doc}//node()[@idref=\"#{old_name}\"]/@idref"
      expr_single = "\"#{new_name}\""
      @connector.update_value(expr, expr_single)
      
      expr = "doc(\"#{@col_path}acl.xml\")//node()[@idref=\"#{old_name}\"]/@idref"
      expr_single = "\"#{new_name}\""
      @connector.update_value(expr, expr_single)
      
      query = "doc(\"#{@col_path}acl.xml\")//node()[@id=\"#{old_name}\"]"
      handle = @connector.execute_query(query)
      hits = @connector.get_hits(handle)
      query = "#{@doc}//node()[@id=\"#{old_name}\"]"
      handle = @connector.execute_query(query)
      hits += @connector.get_hits(handle)
      if(hits == 0)
        puts "Rename succeeded." if @report
      else
        raise RubyACLException.new(self.class.name, __method__, 
          "Failed to rename", 120), caller
      end
    else
      raise RubyACLException.new(self.class.name, __method__,
        "Failed to rename #{self.class.name}. #{self.class.name} \"#{new_name}\" already exists.", 119), caller
    end
    return old_name
  rescue XMLRPC::FaultException => e
    raise e
  rescue => e
    raise e
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
  def find_parents(id)   
    query = "#{@doc}//node()[@id=\"#{id}\"]/membership/*/string(@idref)"
    ids = []
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    hits.times {
      |i|
      id_ref = @connector.retrieve(handle, i)
      if(id_ref=="")
        next      #for unknown reason eXist returns 1 empty hit even any exists therefore unite is skipped (e.g. //node()[@id="all"]/membership/*/string(@idref)
      end
      ids = find_parents(id_ref) | ids | [id_ref]    #unite arrays
    }
    return ids
  rescue => e
    raise e
  end
  
end
