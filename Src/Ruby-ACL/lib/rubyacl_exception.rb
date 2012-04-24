# To change this template, choose Tools | Templates
# and open the template in the editor.

class RubyACLException < RuntimeError
  
  @description
  @number
  
  def initialize(called_class, called_method, _description = "Epic fail \n", _number = nil)
    @clas = called_class
    @method = called_method
    @description = _description + "\n"
    @number  = _number
  end
  def inspect
    self.tostring
  end

  def to_s
    self.tostring
  end

  def tostring
    @number.to_s + ": " + method + "\n" + @description
  end

  def code
    @number
  end
  
  def method
    return "#{@clas}.#{@method}"
  end
end

#List of all exception. In brackets is method, that raise mentioned exception
#ACL_Object:
#0: Name is empty                       (RubyACL.initialize)
#1: Failed to create ACL in database    (RubyACL.create_acl_in_db)
#2: Failed to set new name              (RubyACL.setname)
  
#10: Name is empty                      (ACL_Object.create_new)
#11: ... already exist(s)               (ACL_Object.create_new)
#12: ... was not able to create         (ACL_Object.create_new)
#13: Failed to add membership. Group ... does not exist.    (ACL_Object.add_membership)
#14: Failed to add membership. ... does not exist.          (ACL_Object.add_membership)
#15: Failed to delete membership. Group ... does not exist. (ACL_Object.del_membership)
#16: Failed to delete membership. ... does not exist.       (ACL_Object.del_membership)
#17: Failed to delete #{self.class.name}. #{self.class.name} \"#{name}\" does not exist. (ACL_Object.delete)
#18: Failed to add membership. Membership is in cycle.      (ACL_Object.add_membership)
  
#20: #{self.class.name}                                     (Ace.find_ace)
#Principal=\"#{prin_id}\" and accessType=\"#{acc_type}\" and 
#Privilege=\"#{priv_id}\" and ResourceObject=\"#{res_ob_id}\" 
#exists more then once. (#{hits}x)
#21: #{self.class.name} \"#{id}\" was not able to create.     (Ace.create_new)
#22: Access type #{acc_type} is not allowed. Only allowed type is \"deny\" and \"allow\".   (Ace.create_new)

#30: "#{self.class.name}(type=\"#{type}\", address=\"#{address}\") exists more then once. (#{hits}x)"   (ResourceObject.find_res_ob)
#31: "#{self.class.name}(id=\"#{res_ob_id}\") exists more then once. (#{hits}x)"     (ResourceObject.get_adr)
#32: "#{self.class.name}(id=\"#{res_ob_id}\") exists more then once. (#{hits}x)"     (ResourceObject.get_type)