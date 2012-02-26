class Principal
  @@prin_counter = 0
  
  def initialize(name, member_of = [])
    @id = @@prin_counter
    @name = name
    @member_of = member_of
    @@prin_counter += 1
  end
  
  attr_reader :id, :name, :member_of
  
  def add_membership(member_of)
    @member_of.push(member_of)
  end
  
  def change_name(new_name)
    @name = new_name
  end
  
  def to_s
    return "#{id} \t #{name} \t #{member_of}"
  end
  
  def Principal.prin_counter
    @@prin_counter
  end
  
  public :to_s
  #private :add_membership, :change_name
  
end

