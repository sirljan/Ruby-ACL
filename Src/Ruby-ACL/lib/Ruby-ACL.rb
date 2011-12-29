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
    @principals = []           #pole s principals - docasne reseni, nez se vymysli pripojeni na db
    @privileges = []
    @resource_objects = []     #docasne reseni, nez se vymysli pripojeni na db
    @all = Group.new('all')
    @principals.push(@all)
    create_default_privileges()
    temp_init()
  end
  
  attr_reader :name, :principals, :privileges, :resource_objects # běžné přístupové metody pro čtení
  
  def temp_init()
    @principals.push(Principal.new('sirljan'))
    @principals.push(Principal.new('neubetom'))
    @principals.push(Principal.new('mraztom'))
    @principals.push(Principal.new('silvejan'))
 
    @resource_objects.push(ResourceObject.new(nil,nil,'ryba'))
    @resource_objects.push(ResourceObject.new(nil,nil,'ptak'))
    @resource_objects.push(ResourceObject.new(nil,nil,'kocka'))
  end
  
  def create_default_privileges()
    Privilege.default_privileges.each{ 
      |item| @privileges.push(Privilege.new('allow',item))
      @privileges.push(Privilege.new('deny',item))
    }
  end
  
  def to_s
    puts "Name = #{name} \n\n"
    puts "All available principals:\n"
    for prin in @principals 
      puts "#{prin.id} \t #{prin.name} \t #{prin.member_of}"
    end
    puts "\nAll available privileges: \n"
    for priv in @privileges
      puts "#{priv.access_type} \t #{priv.operation}"
    end
  end
  
  def save()
  end
  
  def load()
  end
  
  def check(principal_name, access_type, privilege_op, resource_object_name)
    array_of_principals_ids = find_all_groups_with_membership_of_principal(principal_name, @principals)
    array_of_principals_ids.push(find_principal(principal_name).id)
    array_of_aces = find_aces(array_of_principals_ids)
    for ace in array_of_aces
      if(ace.privilege.access_type == access_type &&
            ace.privilege.operation == privilege_op && 
            ace.resource_object.name == resource_object_name)
        return true     # access allowed
      end
    end
    return false      # access denied
  end
  
  def find_all_groups_with_membership_of_principal(principal_name, principals)
    selected_prins = []
    temp_select = []
    
    for prin in principals
      if(prin.name == principal_name)
        selected_prins += temp_select
      elsif(prin.class == 'Group')
        temp_select.push(prin.id)
        find_all_groups_with_membership_of_principal(principal_name, prin.members)
      end
    end
    return selected_prins
  end
  
  def find_aces(prin_ids)      #finds all ACEs where principal is included or groups with principal as member
    selected_aces = []
    for ace in @aces
      for prin in prin_ids
        if(ace.principal.id == prin)
          selected_aces.push(ace)
        end
      end
    end
    return selected_aces
  end
  
  def find_principal(principal_name)
    if(principal_name=='')
      #exception
    end
    for prin in @principals
      if (prin.name == principal_name) 
        return prin
      end
    end
    return nil
  end
  
  def find_privilege(access_type, privilege_op)
    for priv in @privileges
      if (priv.operation == privilege_op  && priv.access_type == access_type)
        return priv
      end
    end
    return nil
  end
  
  def find_resource_object(resource_object_name)
    for resource in @resource_objects
      if (resource.name == resource_object_name)
        return resource
      end
    end
    return nil
  end
  
  def existence_of_principals(principals)
    exist = false
    for prin in principals
      if(find_principal(prin))
        exist = true
      end
    end
    return exist
  end
  
  def add_ace(principal_name, access_type, privilege_op, resource_object_name)
    prin = find_principal(principal_name)
    priv = find_privilege(access_type, privilege_op)
    res_ob = find_resource_object(resource_object_name)
    
    if(prin!=nil && priv!=nil && res_ob!=nil)
      @aces[Ace.ace_counter] = Ace.new(prin, priv, res_ob)
      #puts "ACE was created as:\n"
      #puts @aces[Ace.ace_counter - 1]
      
    else
      if(prin==nil)
        puts "Principal \"#{principal_name}\" doesn't exist."
      elsif(priv==nil)
        puts "Privilege \"#{access_type}, #{privilege_op}\" doesn't exist."
      elsif(res_ob==nil)
        puts "Resource object \"#{resource_object_name}\" doesn't exist."
      end
    end
  end
  
  def del_ace
  end
  
  def mod_ace()
  end
  
  def create_principal(name, member_of = [])
    #osetrit name==''
    #existenci name a member_of
  end
  
  def add_membership(name, member_of) #kdyz nebude pole prevest na pole
    if(existance_of_principals(member_of) && find_principal(name)!=nil)
      find_principal(name).add_membership(member_of)
    elsif(!existance_of_principals(member_of))
      puts "One or more Groups metioned in membership parametr don't exist."#exception
    elsif(find_principal(name)==nil)
      puts "Principal \"#{principal_name}\" doesn't exist."
    end
    
  end
  
  def create_group(name, member_of = [], members = [])    #check if it the name already exist. or if member_of and members exist at all
    if(find_pricnipal(name)==nil && existence_of_principals(member_of) && existance_of_principals(members))
      Group.new(name, member_of, members)
    elsif(find_pricnipal(name)!=nil)
      puts "\"#{name.capitalize}\" is already taken by other Principal."  #exception
    elsif(existence_of_principals(member_of))
      puts "One or more Groups metioned in membership parametr don't exist."#exception
    elsif(existence_of_principals(members))
      puts "One or more Groups metioned as members parametr don't exist."#exception
    end
  end
  
  
  public :add_ace, :check, :create_group, :del_ace, :load, :mod_ace, :to_s, :save
  protected
  private :create_default_privileges, :find_aces, 
    :find_all_groups_with_membership_of_principal, 
    :find_principal, :find_privilege, :find_resource_object, :temp_init
    
  
end



#puts 'start'
#mojeacl = Ruby_acl.new("prvniacl")
#puts mojeacl.principals
#mojeacl.add_ace('silvejan', 'allow', 'write', 'ryba')
#
#puts mojeacl.check('silvejan', 'allow', 'write', 'ryba')