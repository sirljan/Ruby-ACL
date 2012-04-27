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
  
#110: Name is empty                      (ACL_Object.create_new)
#111: ... already exist(s)               (ACL_Object.create_new)
#112: ... was not able to create         (ACL_Object.create_new)
#113: Failed to add membership. Group ... does not exist.    (ACL_Object.add_membership)
#114: Failed to add membership. ... does not exist.          (ACL_Object.add_membership)
#115: Failed to delete membership. Group ... does not exist. (ACL_Object.del_membership)
#116: Failed to delete membership. ... does not exist.       (ACL_Object.del_membership)
#117: Failed to delete ... ... does not exist.               (ACL_Object.delete)
#118: Failed to add membership. Membership is in cycle.      (ACL_Object.add_membership)
#119: Failed to rename ... ... already exists                (ACL_Object.rename)
#120: Failed to rename.                                      (ACL_Object.rename)
#121: 
  
#220: #{self.class.name}                                     (Ace.find_ace)
#Principal=\"#{prin_id}\" and accessType=\"#{acc_type}\" and 
#Privilege=\"#{priv_id}\" and ResourceObject=\"#{res_ob_id}\" 
#exists more then once. (#{hits}x)
#221: #{self.class.name} \"#{id}\" was not able to create.     (Ace.create_new)
#222: Access type #{acc_type} is not allowed. Only allowed type is \"deny\" and \"allow\".   (Ace.create_new)
#223: Rename method is not supported for ACE.                (Ace.rename)

#30: "#{self.class.name}(type=\"#{type}\", address=\"#{address}\") exists more then once. (#{hits}x)"   (ResourceObject.find_res_ob)
#31: "#{self.class.name}(id=\"#{res_ob_id}\") exists more then once. (#{hits}x)"     (ResourceObject.get_adr)
#32: "#{self.class.name}(id=\"#{res_ob_id}\") exists more then once. (#{hits}x)"     (ResourceObject.get_type)
#33: #{self.class.name} type=\"#{type}\", address=\"#{address}\" was not able to create.  (ResourceObject.create_new)
#34: Failed to change owner.                               (ResourceObject.change)
#35: Rename method is not supported for resource object     (ResourceObject.rename)
#36: Failed to change #{what_is_changed}. Resource objects doesn't exist.   (ResourceObject.change)