class Group < Principal
  def initialize(name, connector)
    @name = name
    expr = generate_expr()
    #puts expr
    connector.update_insert(expr, "following", "/Principals/Groups/group[last()]")
  end
  
  attr_reader :name
  
  private
  
  def generate_expr()
    expr = <<END
    <group id="#{@name}">
      <membership>
        
      </membership>
    </group>
END
    return expr
  end
  
  def Group.exists?(name, connector)
    #puts "group.exist?"
    #puts "groupname #{name}"
    super(name, connector)
  end
  
  public
  
  def to_s
    super + " \t #{@members} \t group"
  end
  
end