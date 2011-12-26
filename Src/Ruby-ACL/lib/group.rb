class Group < Principal
  def initialize(name, member_of = [], members = [])
    super(name, member_of)
    @members = members
  end
  
  attr_reader :members
  
  def has_member(member)
    for m in @members
      if(member == m.name)
          return true
      end
    end
    return false
  end
  
  def add_members
  end
  
  def to_s
    super + " \t #{@members} \t group"
  end
  
end