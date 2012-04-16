
class ACL_Object
  
  attr_reader :doc
  attr_reader :col_path
  
  def initialize(connector, col_path)
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
  end
  
  def exists?(name, query = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]")
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    if(hits >= 1)
      return true
    else 
      return false
    end
  end
  
  def exist_membership?(name, member_of)        #Is <name> member of <member_of>
    expr = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]/membership/mgroup[@idref=\"#{member_of}\"]"
    exists?(name, expr)
  end
  
  public #------------------PUBLIC----------------------------------------------
  
  def to_s
    return "#{id} \t #{name} \t #{groups}"
  end
  
  def create_new(name, groups)
    bool=true
    if(name == nil || name == '')
      puts "Name is empty."
      bool = false
    end
    if(exists?(name))
      puts "#{self.class.name} \"#{name}\" already exist. Please choose different name."
      bool = false
    end
  
    if(bool)
      expr = generate_expr(name)
      expr_loc = "#{@doc}//#{self.class.name}s/#{self.class.name}[last()]"
      @connector.update_insert(expr, "following", expr_loc)
      if(exists?(name))
        #puts "New #{self.class.name} \"#{name}\" created."
      else
        puts "#{self.class.name} \"#{name}\" was not able to create."
      end
    end
    if(groups.length > 0)
      add_membership(name, groups, true)
    end
  end
    
  #adds acl object into group(s); if you know prin exists set true for prin_exists
  def add_membership(name, groups, ob_exists = false) 
    if(ob_exists || exists?(name))
      for group in groups
        if(!exists?(group))
          #TODO udelat neco s warningama
          puts "WARNING: Group \"#{group}\" does not exist."
        end
        expr = "<mgroup idref=\"#{group}\"/>"
        expr_single = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]/membership"
        @connector.update_insert(expr, "into", expr_single)
      end
    else
      raise RubyACLException.new("Failed to add membership. #{self.class.name} \"#{name}\" does not exist.", 1), 
        "Failed to add membership. #{self.class.name} \"#{name}\" does not exist.", caller
    end
  end
  
  def del_membership(name, groups) #deletes prin_name from group(s)
    if(exists?(name))
      for group in groups
        #if(exist_membership?)
        expr = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]/membership/mgroup[@idref=\"#{group}\"]"
        @connector.update_delete(expr)
        #end
        if(!exists?(group))
          puts "WARNING: #{self.class.name} \"#{group}\" does not exist."
        end
      end
    else
      puts "#{self.class.name} with name \"#{name}\" does not exist."
      raise RubyACLException.new("Failed to delete membership", 2), "Failed to delete membership", caller
    end
  end
  
  def delete(name)
    if(exists?(name))
      expr = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]"
      @connector.update_delete(expr)
    else
      puts "WARNING: #{self.class.name} \"#{name}\" does not exist."
    end
    return name
  end
  
  def rename(old_name, new_name)
    
  end
  
  def ge(temp_ace, final_ace, grid)
    t = grid.find_index(temp_ace.priv)
    f = grid.find_index(final_ace.priv)
    if(t >= f)
      return true
    else
      return false
    end
  end
  
end
