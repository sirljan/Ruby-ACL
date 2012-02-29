class Group < Principal
  def initialize(name, member_of = [], members = [])
    super(name, member_of)
    @members = members
  end
  
  attr_reader :members
  
  private
  
  def has_member(member)
    for m in @members
      if(member == m.name)
          return true
      end
    end
    return false
  end
  
  def Group.exists?(group, connector)
    #puts "group.exist?"
    #puts "groupname #{name}"
    super(group, connector, "/acl/Principals/Groups/principal[name=\"#{group}\"]")
  end
  
  public
  
  def add_members()
  end
  
  def to_s
    super + " \t #{@members} \t group"
  end
  
end