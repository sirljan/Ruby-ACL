class Accessor < Principal     #user, proces or whoever is accessing resource objects
  #mel by byt Is A Child Principal stejne jako Group
  def initialize(id, name, member_of)
    super(id, name, member_of)   #initialize of ancestor Principal
  end
end