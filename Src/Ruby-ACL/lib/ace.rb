class Ace
  @@ace_counter = 0
  def initialize(principal, privilege, resource_object)
    @id = @@ace_counter
    @principal = principal
    @privilege = privilege
    @resource_object = resource_object
    @@ace_counter += 1
  end
  
  attr_reader :id, :principal, :privilege, :resource_object
  
  def to_s
    "#{principal.id} \t #{principal.name} \t #{privilege.access_type} \t #{privilege.operation} \t #{resource_object.name}"
  end
    
  def Ace.ace_counter
    @@ace_counter
  end
  
  public :to_s
  
end