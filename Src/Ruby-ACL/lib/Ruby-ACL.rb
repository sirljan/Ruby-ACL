$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/lib")
require 'principal'
require 'accessor'
require 'group'
require 'privilege'
require 'resource_object'
require 'ace'
require 'main'


class RubyACL
  def initialize(name, connector)
    @name = name
    @connector = connector
    @colpath = "/db/acl/"
    create_acl_in_db()
    #@aces = []
    #@principals = []           #pole s principals - docasne reseni, nez se vymysli pripojeni na db
    #@privileges = []
    #@resource_objects = []     #docasne reseni, nez se vymysli pripojeni na db
    #@all = Group.new('all')   #root group
    #@principals.push(@all)
  end
  
  attr_reader :name, :aces, :privileges, :resource_objects # běžné přístupové metody pro čtení
  
  private   #follow private methods
  
  def create_acl_in_db()
    col = @connector.getcollection(@colpath)
    if(col.name != @colpath)
      puts "Kolekce neexistuje. Vytvarim kolekci."
      @connector.createcollection(@colpath)
      col = @connector.getcollection(@colpath)
    end
    if(col['acl.xml'] == nil)
      puts "Zdrojovy soubor neexistuje. Vytvarim soubor."
      xmlfile = File.read("acl.xml")
      @connector.storeresource(xmlfile, @colpath + "acl.xml")
      col = @connector.getcollection(@colpath)
    end
    if(col.name == @colpath && col['acl.xml'] != nil)
      puts "Kolekce i zdrojovy soubor pro acl existuje"
      doc = col['acl.xml']
      doc.to_s
    else
      puts "Kolekce nebo zdrojovy soubor pro acl neexistuje"
    end
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
  
  protected

  public              # follow public methods
  
  def to_s
    puts "Name = #{@name} \n\n"
    col = @connector.getcollection(@colpath)
    doc = col['acl.xml']
    doc.content
  end
  
  def save(filename)
    filename=filename + ".xml"
    col = @connector.getcollection(@colpath)
    doc = col['acl.xml']
    f = File.new(filename, 'w')
    f.puts(doc.content)    
    f.close
  end
  
  def RubyACL.load(filename, connector)
    @connector = connector
    @colpath = "/db/acl/"
    @connector.remove_collection(@colpath)
    @connector.createcollection(@colpath)
    #osetrit nacitani souboru - vyjimka pri neexistujicim souboru
    xmlfile = File.read(filename)
    @connector.storeresource(xmlfile, @colpath + "acl.xml")
    handle = @connector.execute_query("/acl/string(@aclname)")
    @name = @connector.retrieve(handle,0)
    puts @name
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
        puts "Principal \"#{principal_name}\" doesn't exist."#exception
      elsif(priv==nil)
        puts "Privilege \"#{access_type}, #{privilege_op}\" doesn't exist."#exception
      elsif(res_ob==nil)
        puts "Resource object \"#{resource_object_name}\" doesn't exist."#exception
      end
    end
  end
  
  def del_ace(ace_id)
  end
  
  def mod_ace()
  end
  
  def create_principal(name, groups = [])
    
    #osetrit name==''
    #existenci name a groups
    bool=true
    if(name == nil || name == '')
      puts "Name is empty."
      bool=false
    end
    if(Principal.exists?(name, @connector))
      puts "Principal \"#{name}\" already exist. Please choose different name."
      bool=false
    end
  
    if(bool)
      Principal.new(name, @connector)
      puts "New principal \"#{name}\" created."
    end
    add_membership(name, groups, true)
    
  end
  
  def add_membership(prin_name, groups = [], prin_exists=false) #kdyz nebude pole prevest na pole
    if(prin_exists || Principal.exists?(prin_name, @connector))
      for group in groups
        if(Group.exists?(group,@connector))
          @connector.update_insert("<member>#{prin_name}</member>", "into",
            "/acl/Principals/Groups/principal[name=\"#{group}\"]/members")
        else
          puts "WARNING: Group \"#{group}\" does not exist."
        end
        @connector.update_insert("<group>#{group}</group>", "into",
          "/acl/Principals/Individuals/principal[name=\"#{prin_name}\"]/membership")
      end
    else
      puts "Principal with name \"#{prin_name}\" does not exist."
    end
  end
  
  def create_group(name, groups = [], members = [])    #check if it the name already exist. or if groups and members exist at all
    if(find_pricnipal(name)==nil && existence_of_principals(groups) && existance_of_principals(members))
      Group.new(name, groups, members)
    elsif(find_pricnipal(name)!=nil)
      puts "\"#{name.capitalize}\" is already taken by other Principal."  #exception
    elsif(existence_of_principals(groups))
      puts "One or more Groups metioned in membership parametr don't exist."#exception
    elsif(existence_of_principals(members))
      puts "One or more Groups metioned as members parametr don't exist."#exception
    end
  end
end


$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/eXistAPI/lib")
require "eXistAPI"

db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")

#jineacl = RubyACL.load("pokus.xml", db)
#jineacl.to_s
puts "Deleting old ACL from db for testing purposes."
db.remove_collection("/db/acl/")
puts 'Creating new acl'
mojeacl = RubyACL.new("prvniacl", db)
#puts Print of acl
#puts mojeacl.to_s
puts "Creating new principal"
groups = ['Administrators', 'Users', 'Developers', 'Houbari']
mojeacl.create_principal("neubetom", groups)
mojeacl.create_principal("silvejan")
mojeacl.add_membership("silvejan",groups)
puts "Saving acl from db to local file."
mojeacl.save("pokus")






#mojeacl.add_ace('silvejan', 'allow', 'write', 'ryba')
#
#puts mojeacl.check('silvejan', 'allow', 'write', 'ryba')

