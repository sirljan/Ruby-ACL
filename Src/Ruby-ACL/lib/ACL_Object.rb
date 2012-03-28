# To change this template, choose Tools | Templates
# and open the template in the editor.

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
  
  def exists?(name, query = "#{@doc}/#{self.class.name}s/descendant::*[@id=\"#{name}\"]")
    #puts "principal.exists?"
    #puts "guery #{query}"
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    #puts "hits #{hits}"
    if(hits >= 1)
      return true
    else 
      return false
    end
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
      #puts "#{self.class.name} \"#{name}\" already exist. Please choose different name."
      bool = false
    end
  
    if(bool)
      expr = generate_expr(name)
      #puts expr
      expr_loc = "#{@doc}/#{self.class.name}s/#{self.class.name}[last()]"
      #puts expr_loc
      @connector.update_insert(expr, "following", expr_loc)
      if(exists?(name))
        #puts "New #{self.class.name} \"#{name}\" created."
      else
        #puts "#{self.class.name} \"#{name}\" was not able to create."
      end
    end
    if(groups.length > 0)
      add_membership(name, groups, true)
    end
  end
    
  def add_membership(name, groups = [], ob_exists = false) #adds acl object into group(s); if you know prin exists set true for prin_exists
    if(ob_exists || exists?(name))
      #puts "podminka"
      #puts prin_name
      for group in groups
        if(!exists?(group, @connector))
          puts "WARNING: Group \"#{group}\" does not exist."
        end
        expr = "<mgroup idref=\"#{group}\"/>"
        #expr = '<group xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="acl.xml#'+"#{group}"+"\"/>"
        expr_single = "#{@doc}/#{self.class.name}s/descendant::*[@id=\"#{name}\"]/membership"
        #puts expr_single
        @connector.update_insert(expr, "into", expr_single)
      end
    else
      puts "#{self.class.name} with name \"#{name}\" does not exist."
    end
  end
  
  def del_membership(name, groups) #deletes prin_name from group(s)
    if(exists?(name, @connector))
      for group in groups
        if(exists?(group, @connector))
          expr = "#{@doc}/#{self.class.name}s/descendant::*[@id=\"#{name}\"]/membership/group[@idref=\"#{group}\"]"
          @connector.update_delete(expr)
        else
          puts "WARNING: Can not delete membership in \"#{group}\". Group \"#{group}\" does not exist."
        end
      end
    else
      puts "#{self.class.name} with name \"#{name}\" does not exist."
    end
  end
  
  def delete(name)
    if(Principal.exists?(name, @connector))
      expr = "#{@doc}/#{self.class.name}s/descendant::*[@id=\"#{name}\"]"
      @connector.update_delete(expr)
    else
      puts "#{self.class.name} with name \"#{name}\" does not exist."
    end
  end
  
  def rename(old_name, new_name)
    
  end
  
  
end
