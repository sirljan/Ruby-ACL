require './principal'
require './accessor'
require './group'
require './privilege'
require './resource_object'
require './ace'



class Ruby_acl
  def initialize(name)
    @name = name
    @aces = []
    @allprincipals = []           #pole s principals - docasne reseni, nez se vymysli pripojeni na db
    @allprivileges = []
    @allresource_objects = []     #docasne reseni, nez se vymysli pripojeni na db
    create_default_privileges()
    temp_init()
  end
  
  attr_reader :name, :allprincipals, :allprivileges, :allresourceobjects # běžné přístupové metody pro čtení
  
  def printme
    puts "Name = #{name} \n\n"
    puts "All available principals:\n"
    for prin in @allprincipals 
      puts "#{prin.id} \t #{prin.name} \t #{prin.member_of}"
    end
    puts "\nAll available privileges: \n"
    for priv in @allprivileges
      puts "#{priv.access_type} \t #{priv.operation}"
    end
  end
  
  def check(principal_name, access_type, privilege_op, resource_object_name)
    array_of_principals = find_all_groups_with_membership_of_principal(principal_name)
    array_of_aces = find_aces(array_of_principals)
    for ace in array_of_aces
      if(ace.privilege.access_type == access_type &&
            ace.privilege.operation == privilege_op && 
            ace.resource_object.name == resource_object_name)
        return true     # access allowed
      end
      return false      # access denied
    end
  end
  
  def find_all_groups_with_membership_of_principal(principal_name)
    
  end
  
  def find_aces(principals)
    
  end
  
  def save()
  end
  
  def load()
  end
  
  def del_ace
  end
  
  def mod_ace()
  end
  
  def temp_init()
    
    @allprincipals.push('sirljan')
    @allprincipals.push('neubetom')
    @allprincipals.push('mraztom')
    @allprincipals.push('silvejan')
 
    @allresource_objects.push(nil,nil,'ryba')
    @allresource_objects.push(nil,nil,'ptak')
    @allresource_objects.push(nil,nil,'kocka')
    
  end
  
  def create_default_privileges()
    Privilege.default_privileges.each{ 
      |item| @allprivileges.push(Privilege.new('allow',item))
      @allprivileges.push(Privilege.new('deny',item))
      }
  end
  
  def find_principal_by_name(principal_name)
    for each in @allprincipals
      if (each == principal_name) 
        return each
      end
    end
    return nil
  end
  
  def find_privilege(access_type, privilege_op)
    for each in @allprivileges
      if (each.operation == privilege_op  && each.access_type == access_type)
        return each
      end
    end
    return nil
  end
  
  def find_resource_object(resource_object)
    for name in @allresource_objects
      if name == resource_object
        return true
      end
    end
    return false
  end
  
  def add_ace(principal_name, access_type, privilege_op, resource_object_name)
    prin = does_exist_principal(principal_name)
    priv = find_privilege(access_type, privilege_op)
    res_ob = find_resource_object(resource_object_name)
    
    if(prin!=nil && priv!=nil && res_ob!=nil)
      puts "vsechno existuje"
      @aces[Ace.ace_counter] = Ace.new(prin, priv, res_ob)
    else
      puts "neco neexistuje"
    end
  end
end


puts 'start'
mojeacl = Ruby_acl.new("prvniacl")
mojeacl.add_ace('silvejan', 'allow', 'write', 'ryba')
