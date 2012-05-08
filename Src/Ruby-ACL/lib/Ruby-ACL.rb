$:.unshift("./lib")
$:.unshift(".")
require 'ACL_Object'
require 'Principal'
require 'individual'
require 'group'
require 'privilege'
require 'resource_object'
require 'ace'
require 'date'
require 'ace_rule'
require 'rubyacl_exception'

class RubyACL
  
  # common access methods
  attr_reader :name
  attr_reader :col_path
  
  #Creates new instance of Ruby-ACL. Ruby-ACL works if principals, privileges and resource object.
  #With Ruby-ACL you can manage permsion to person for resource objects.
  #
  # * *Args*    :
  #   - +name+ -> name of the ACL
  #   - +connector+ ->  instance of connection manager with db. e.g. ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")    
  #   - +colpath+ -> path of collection in db. e.g. "/db/acl/"
  #   - +src_files_path+ -> path of source files in local location.
  #   - +report+ -> boolean - if true Ruby-ACL 
  # * *Returns* :
  #   - instance of RubyACL
  # * *Raises* :
  #   - +RubyACLException+ -> Name is empty
  def initialize(name, connector, colpath = "/db/acl/", src_files_path = "./src_files/", report = false)
    if(name == "")
      raise RubyACLException.new(self.class.name, __method__, "Name is empty", 0), caller
    end
    @name = name
    @connector = connector
    if(colpath[-1] != "/")
      colpath += "/"
    end
    @col_path = colpath
    @src_files_path = src_files_path
    @report = report
    @prin = Principal.new(@connector, @col_path, @report)
    @indi = Individual.new(@connector, @col_path, @report)
    @group = Group.new(@connector, @col_path, @report)
    @priv = Privilege.new(@connector, @col_path, @report)
    @res_obj = ResourceObject.new(@connector, @col_path, @report)
    @ace = Ace.new(@connector, @col_path, @report)
    create_acl_in_db()
    rename(name)
  rescue => e
    raise e
  end
  
  private   # private methods follow
  
  #
  #
  # * *Args*    :
  #   - +none+
  # * *Returns* :
  #   - report note if report = true
  # * *Raises* :
  #   - +RubyACLException+ -> Failed to create ACL in database
  #
  def create_acl_in_db()
    if(!@connector.existscollection?(@col_path))
      #puts "Collection doesn't exist. Creating collection."
      @connector.createcollection(@col_path)
    end
    col = @connector.getcollection(@col_path)
    sfs = missing_src_files(col)
    if(sfs != [])   #creates array of documents that dont exist in collection
      missing_files = ""
      sfs.each { |sf| 
        missing_files = missing_files + '"'+sf+'"' 
        if(sf != sfs.last())
          missing_files = missing_files + ", "
        end
      }
      #Creating new source file(s)
      for sfile in sfs
        xmlfile = File.read(@src_files_path + sfile)
        @connector.storeresource(xmlfile, @col_path + sfile)
      end
      col = @connector.getcollection(@col_path)
    end
    
    if(col.name == @col_path && missing_src_files(col) == [])
      puts "ACL collection with source files created." if @report
    else
      raise RubyACLException.new(self.class.name, __method__, "Failed to create ACL in database", 1), caller
    end
  rescue XMLRPC::FaultException => e
    raise e
  rescue => e
    raise e
  end
  
  def missing_src_files(col)   #returns array of files that are not present in acl collection
    files = []
    if(col['acl.xml'] == nil)
      files.push('acl.xml')
    end
    if(col['Principals.xml'] == nil)
      files.push('Principals.xml')
    end
    if(col['Privileges.xml'] == nil)
      files.push('Privileges.xml')
    end
    if(col['ResourceObjects.xml'] == nil)
      files.push('ResourceObjects.xml')
    end
    return files
  end
  
  def decide(res)
    #puts "decide"
    if(res == "allow")
      return true
    elsif(res == "deny")
      return false
    end
  end
  
  #Returns ACE that has higher priority.
  #Lowest number has highest priority:
  #1. Owner  - owner is handled in method check
  #2. Explicit Deny
  #3. Explicit Allow
  #4. Inherited Deny
  #5. Inherited Allow
  #6. If not found then Access denied
  #
  # * *Args*    :
  #   - +final_ace+ -> first ace to compare
  #   - +temp_ace+  -> second ace to compare
  # * *Returns* :
  #   - returns ace that has higher priority
  # * *Raises* :
  #   - +RubyACLException+ -> Failed to create ACL in database
  #
  def compare(final_ace, temp_ace)   #returns ace that has higher priority
    if(final_ace == nil)
      return temp_ace
    end
    
    if(@prin.eq(temp_ace, final_ace) && final_ace.acc_type == "deny")
      if(@priv.ge(temp_ace, final_ace, @privs) && @res_obj.ge(temp_ace, final_ace, @res_obs))
        final_ace = temp_ace
      end
    end
    
    if(@prin.ne(temp_ace, final_ace))
      if(@priv.ge(temp_ace, final_ace, @privs) && @res_obj.ge(temp_ace, final_ace, @res_obs))
        final_ace = temp_ace
      end
    end
    return final_ace
  rescue => e
    raise e
  end
  
  #Prepares query in xQuery language. This query selects all ace that has 
  #principale && one of the privileges && one of the resource objects.
  #
  #
  # * *Args*    :
  #   - +prin+ -> principal
  #   - +privs+ -> privilege and all parental privileges
  #   - +res_obs+ -> resource object and all parental resource objects
  # * *Returns* :
  #   - query in string
  # * *Raises* :
  #   - +nothing+
  #
  def prepare_query(prin, privs, res_obs)
    query = <<END
for $ace in #{@ace.doc}//Ace
where (
END
    
    query += "($ace/Principal/@idref=\"#{prin}\")"
    
    query += " and ("
    for priv in privs
      query += "$ace/Privilege/@idref=\"#{priv}\""
      if(priv != privs.last)
        query+=" or "
      else
        query+=") "
      end
    end
    
    query += " and ("
    for res_ob in res_obs
      query += "$ace/ResourceObject/@idref=\"#{res_ob}\""
      if(res_ob != res_obs.last)
        query+=" or "
      else
        query+=") "
      end
    end
    query+=")"
    query += "return $ace/string(@id)"
    return query 
  rescue => e
    raise e
  end
  
  def is_owner?(prin_name, res_obs)
    #In array res_obs are all optencial res_obs
    #transform array into string if id="something" OR id=... and so
    res_obs = prepare_res_obs(res_obs)    
    #Select only those resOb that have wanted owner.
    query = "#{@res_obj.doc}//ResourceObject[#{res_obs} and owner/string(@idref)=\"#{prin_name}\"]" 
    #puts query
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    if(hits>0)    #if owner exist, lets grand access
      return true
    else
      return false
    end
  rescue => e
    raise e
  end
  
  #Creates part of the query. Inserts "or" between each of resource object and whole string is in ()
  #
  # * *Args*    :
  #   - +res_obs+ -> array of resource objects
  # * *Returns* :
  #   -string
  # * *Raises* :
  #   - +nothing+
  #
  def prepare_res_obs(res_obs)
    str = "("
    for res_ob in res_obs
      str = str + "@id=\""
      str += res_ob
      str += "\" or "
    end
    str = str[0..-4]    #delete last " OR "
    str += ")"
    return str
  end
  
  #Creates ace in acl.xml in db
  #
  # * *Args*    :
  #   - +prin_name+ -> name of the principal
  #   - +acc_type+ -> access type. allow to allow. deny to revoke
  #   - +priv_name+ -> name of the privilege
  #   - +res_ob_type+ -> type of resource object
  #   - +res_ob_adrs+ -> address of resource object.
  # * *Returns* :
  #   -id of ace
  # * *Raises* :
  #   - +nothing+
  #
  def insert_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    res_ob_id = @res_obj.find_res_ob(res_ob_type, res_ob_adrs)
    if(res_ob_id == nil)
      res_ob_id = @res_obj.create_new(res_ob_type, res_ob_adrs, prin_name)
    end
    id = @ace.create_new(prin_name, acc_type, priv_name, res_ob_id)
    return id
  end
  
  protected

  public              # follow public methods
  
  #Renames acl (also in db)
  #
  # * *Args*    :
  #   - +new_name+ -> new name of acl
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +RubyACLException+ -> Failed to set new name
  #
  def rename(new_name)
    query = "update value doc(\"#{@col_path}acl.xml\")/acl/@aclname with \"#{new_name}\""
    @connector.execute_query(query)
    query = "doc(\"#{@col_path}acl.xml\")/acl/string(@aclname)"
    handle = @connector.execute_query(query)
    if(new_name != @connector.retrieve(handle, 0))
      raise RubyACLException.new(self.class.name, __method__, "Failed to set new name", 2), caller
    end
  rescue XMLRPC::FaultException => e
    raise e
  rescue => e
    raise e
  end
  
  #It saves/backs up acl
  #
  # * *Args*    :
  #   - +path+ -> to local location
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def save(path, date = false)
    #TODO proverit
    col = @connector.getcollection(@col_path)    
    docs = col.docs()
    if(date)
      path = path + Date.today.to_s + "/"
    end
    if(!File.exists?(path))
      Dir.mkdir(path)
    end
    docs.each{|doc| 
      document = col[doc] 
      #doc = doc + "_BU"
      filename = path + doc
      f = File.new(filename, 'w')
      f.puts(document.content)
      f.close
    }
  rescue => e
    raise e
  end
  
  #It loads backuped acl data.
  #
  # * *Args*    :
  #   - +connector+ ->  instance of connection manager with db. e.g. ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")    
  #   - +colpath+ -> path of collection in db. e.g. "/db/acl/"
  #   - +src_files_path+ -> path of source files in local location.
  #   - +report+ -> boolean - if true Ruby-ACL 
  # * *Returns* :
  #   -new instance of Ruby-ACL
  # * *Raises* :
  #   - +nothin+
  #
  def RubyACL.load(connector, colpath = "/db/acl/", src_files_path, report)
    #TODO proverit
    xmlfile = File.read(src_files_path+"acl.xml")
    startindex = xmlfile.index('"', xmlfile.index("aclname="))
    endindex = xmlfile.index('"', startindex+1)
    name = xmlfile[startindex+1..endindex-1]
    newacl = RubyACL.new(name, connector, colpath, src_files_path, report)
    return newacl
  rescue => e
    raise e
  end
  
  
  #Decides whether principal has privilege or not to resource object identified 
  #by access type and address. If the accessType of ace is allow - returns true. 
  #If accessType of ace is deny return false.
  #
  #Priority of decision is as follows lower. 
  #Lowest number has highest priority:
  #1. Owner
  #2. Explicit Deny
  #3. Explicit Allow
  #4. Inherited Deny
  #5. Inherited Allow
  #6. If not found then Deny
  #  
  # * *Args*    :
  #   - +prin_name+ -> name of the principal
  #   - +priv_name+ -> name of the privilege
  #   - +res_ob_type+ -> type of the resource object
  #   - +res_ob_adr+ -> address of the resource object
  # * *Returns* :
  #   -boolean - true - has privilege to resource object, false - has not
  # * *Raises* :
  #   - +nothing+
  #
  def check(prin_name, priv_name, res_ob_type, res_ob_adr)
    res_ob_id = @res_obj.find_res_ob(res_ob_type, res_ob_adr)
    #creates the set of resOb (wanted resOb and all resOb from root to address, unsorted)
    @res_obs = @res_obj.find_res_ob_parents(res_ob_type, res_ob_adr) 
    #adds resOb, which ends with /* + wanted resOb
    @res_obs = @res_obj.res_obs_grand2children(@res_obs) + [res_ob_id]  
    
    if(is_owner?(prin_name, @res_obs))
      #puts "owner"
      return true   #access allowed - owner can do everything
    end
    
    #creates the set of principals {wanted principal and all groups wanted principal is member of}
    prins = @prin.find_parents(prin_name) + [prin_name]    
    @privs = @priv.find_parents(priv_name) + [priv_name]   #same for privilege
    
    final_ace = nil
    for prin in prins
      #ask for principal with privilege or higher privileges and and resob or higher resob. 
      query = prepare_query(prin, @privs, @res_obs)   
      #puts query
      handle = @connector.execute_query(query)
      hits = @connector.get_hits(handle)
      #puts "hits #{hits}"
      if(hits > 0)   
        temp_id = @connector.retrieve(handle, 0)   #retrieve id of first Ace
        temp_ace = AceRule.new(temp_id, @ace, @connector)
        if(hits == 1)
          final_ace = compare(final_ace, temp_ace)
        else    #there are more rules
          hits.times { |i|
            temp_id = @connector.retrieve(handle, i)   #retrieve id of next Ace
            temp_ace.reload!(temp_id)
            final_ace = compare(final_ace, temp_ace)
          }
        end
      end
    end
    
    if(final_ace == nil)  #Rule doesnt exist = access denied
      #puts "nil"
      puts "Required rule 
(#{prin_name}, #{priv_name}, #{res_ob_type}, #{res_ob_adr}) does not exist. 
Access denied." if @report
      return false
    else
      return decide(final_ace.acc_type)
    end
  rescue => e
    raise e
    #puts e.backtrace.join("\n")
    #raise RubyACLException.new(self.class.name, __method__, "Failed to check ACE", 3), caller
  end
  
  #It shows permissions for principal all its parents.
  #
  # * *Args*    :
  #   - +prin_name+ -> name of the principal
  # * *Returns* :
  #   -string -> all aces that has principal and all its parents.
  # * *Raises* :
  #   - +nothing+
  #
  def show_permissions_for(prin_name)
    #creates the set of principals {wanted principal and all groups wanted principal is member of}
    prins = [prin_name] + @prin.find_parents(prin_name)
    
    #creates query, ask for principal permisions and all his parents permisions
    query = "for $ace in #{@ace.doc}//Ace where ("    
    for prin in prins
      query += "($ace/Principal/@idref=\"#{prin}\") or"
    end
    query = query[0..-4]    #delete last or
    query += ") return $ace"
    
    ace = ""  
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    hits.times { |i|
      ace = ace + @connector.retrieve(handle, i) + "\n"  #retrieve and add next ACE
    }
    ace = ace[0..-2]    #delete last \n
    return ace
  rescue => e
    raise e
  end
  
  #Creates ace in acl. If resource object doesn't exist it creates resource object first.
  #
  #Address:
  #If is used:
  #  resource address /something/somethingelse and grand2children = true
  #  then will be created access for somthingelse and its children
  #If is used:  
  #  only /something/somethingelse/*
  # then will be created access only to somethingelse's children
  #
  #
  # * *Args*    :
  #   - +prin_name+ -> name of the principal
  #   - +acc_type+ -> access type. True = grant, false = revoke
  #   - +priv_name+ -> name of the privilege
  #   - +res_ob_type+ -> type of the resource object
  #   - +res_ob_adr+ -> address of the resource object
  #   - +grand2children+ -> boolean. 
  #         True = grant to all children. 
  #         False = grant only to specified resource object
  # * *Returns* :
  #   - id of the created ace
  # * *Raises* :
  #   - +nothing+
  #
  def create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adr, grand2children = false)
    if(res_ob_adr[-2..-1] == "/*")
      id = insert_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adr)
    else
      id = insert_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adr)
      if(grand2children)
        res_ob_adr = res_ob_adr + "/*"
        insert_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adr)
      end
    end
    return id
  rescue => e
    raise e
  end
  
  #It creates principal with name and membership in groups.
  #
  # * *Args*    :
  #   - +name+ -> name of the princpal
  #   - +groups+ -> array of groups where principal will be member.
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def create_principal(name, groups = ["ALL"])
    @indi.create_new(name, groups)
  rescue => e
    raise e
  end
  
  #Create group with name and membership in groups and members as groups or individual
  #
  #Note:
  # members can be groups or individuals; 
  # At first method check if the name already exist. Or if groups and members exist at all
  #
  # * *Args*    :
  #   - +name+ -> name of the new group
  #   - +member_of+ -> array of groups where new group will be member.
  #   - +members+ -> array of principals, who will be members of new group
  #       members can be groups or individuals; 
  #       check if it the name already exist. Or if groups and members exist at all
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def create_group(name, member_of = ["ALL"], members = [])    
    @group.create_new(name, member_of, members)   
  rescue => e
    raise e
  end
  
  #It creates privilege with name and membership in specified privileges.
  #
  # * *Args*    :
  #   - +name+ -> name of the privilege
  #   - +member_of+ -> array of privileges where new privilege will be member.
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def create_privilege(name, member_of = ["ALL_PRIVILEGES"])
    @priv.create_new(name, member_of)
  rescue => e
    raise e
  end
  
  #It creates resource object with type, address and owner.
  #
  # * *Args*    :
  #   - +type+ -> type of resource object. e.g. doc, room, file, collection
  #   - +address+ -> address of the resource object. If it ends with /*, it means all children
  #   - +owner+ -> owner of the resource object
  # * *Returns* :
  #   - id of the created resource object
  # * *Raises* :
  #   - +nothing+
  #
  def create_resource_object(type, address, owner)
    #puts "type #{type} add #{address}"
    id = @res_obj.create_new(type, address, owner)
    return id
  rescue => e
    raise e
  end
  
  #It changes resource object's type. 
  #Address and type must be specified to identify resource object.
  #
  # * *Args*    :
  #   - +type+ -> type of resource object
  #   - +address+ ->  address of resource object
  #   - +new_type+ -> new_type of resource object
  # * *Returns* :
  #   - nothing
  # * *Raises* :
  #   - +nothing+
  #
  def change_res_ob_type(type, address, new_type)
    @res_obj.change_type(type, address, new_type)
  rescue => e
    raise e
  end
  
  #It changes resource object's address. 
  #Address and type must be specified to identify resource object.
  #
  # * *Args*    :
  #   - +type+ -> type of resource object
  #   - +address+ ->  address of resource object
  #   - +new_address+ -> new address of resource object
  # * *Returns* :
  #   - nothing
  # * *Raises* :
  #   - +nothing+
  #
  def change_of_res_ob_address(type, address, new_address)
    @res_obj.change_address(type, address, new_address)
  rescue => e
    raise e
  end
  
  #It changes resource object's owner. 
  #Address and type must be specified to identify resource object.
  #
  # * *Args*    :
  #   - +type+ -> type of resource object
  #   - +address+ ->  address of resource object
  #   - +new_owner+ -> new owner of resource object
  # * *Returns* :
  #   - nothing
  # * *Raises* :
  #   - +nothing+
  #
  def change_of_res_ob_owner(type, address, new_owner)
    @res_obj.change_owner(type, address, new_owner)
  rescue => e
    raise e
  end
  
  #It renames any principal. It means either individual or group.
  #
  # * *Args*    :
  #   - +old_name+ -> old name of principal
  #   - +new_name+ ->  new name of principal
  # * *Returns* :
  #   - nothing
  # * *Raises* :
  #   - +nothing+
  #
  def rename_principal(old_name, new_name)
    @prin.rename(old_name, new_name)
  end
  
  #It renames privilege.
  #
  # * *Args*    :
  #   - +old_name+ -> old name of privilege
  #   - +new_name+ ->  new name of privilege
  # * *Returns* :
  #   - nothing
  # * *Raises* :
  #   - +nothing+
  #
  def rename_privilege(old_name, new_name)
    @priv.rename(old_name, new_name)
  end
  
  #It adds principal into group(s) as member.
  #
  # * *Args*    :
  #   - +name+ -> name of the principal
  #   - +groups+ -> array of groups, where principal will be member.
  #   - +existance+ ->  boolean. If you know that principal exists set true for existance. 
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #  
  def add_membership_principal(name, groups, existance = false) 
    @prin.add_membership(name, groups, existance)
  rescue => e
    raise e
  end
  
  #It adds privilege into privilege(s). So you can gather privileges into tree.
  #
  # * *Args*    :
  #   - +name+ -> name of the privilege
  #   - +groups+ -> array of privileges, where privilege will be member.
  #   - +existance+ ->  boolean. If you know that privielge exists set true for existance. 
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def add_membership_privilege (name, groups, existance = false) 
    @priv.add_membership(name, groups, existance)
  rescue => e
    raise e
  end
  
  #It removes principal from group(s) where principal is member.
  #
  # * *Args*    :
  #   - +name+ -> name of the principal
  #   - +groups+ -> array of groups, where principal is member.
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #  
  def del_membership_principal(prin_name, groups) #deletes prin_name from group(s)
    @prin.del_membership(prin_name, groups)
  rescue => e
    raise e
  end
  
  #It removes the privilege from parental privilege(s) where the privilege is member.
  #
  # * *Args*    :
  #   - +name+ -> name of the privilege
  #   - +groups+ -> array of groups, where privilege is member.
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #  
  def del_membership_privilege(priv_name, groups) #deletes prin_name from group(s)
    @priv.del_membership(priv_name, groups)
  rescue => e
    raise e
  end
  
  #It deletes principal from ACL. It also deletes all linked ACEs.
  #
  # * *Args*    :
  #   - +name+ -> name of the principal
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def delete_principal(name)
    @prin.delete(name)
  rescue => e
    raise e
  end
  
  def delete_privilege(name)
    @priv.delete(name)
  rescue => e
    raise e
  end
  
  #It deletes resource object from ACL. It also deletes all linked ACEs.
  #
  # * *Args*    :
  #   - +type+ -> type of the resource object
  #   - +address+ -> address of the resource object
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def delete_res_object(type, address)
    res_ob_id = @res_obj.find_res_ob(type, address)
    @res_obj.delete(res_ob_id)
    return res_ob_id
  rescue => e
    raise e
  end
  
  #It deletes resource object from ACL by id. It also deletes all linked ACEs.
  #
  # * *Args*    :
  #   - +id+ -> id of the resource object
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def delete_res_object_by_id(id)
    @res_obj.delete(id)
  rescue => e
    raise e
  end
  
  #It deletes ACE from ACL.
  #
  # * *Args*    :
  #   - +ace_id+ -> id of the ACE
  # * *Returns* :
  #   -nothing
  # * *Raises* :
  #   - +nothing+
  #
  def delete_ace(ace_id)
    @ace.delete(ace_id)
  rescue => e
    raise e
  end

  
end

#TODO Vzorovou tridu API s vyhazovanim vyjimek must be implemented
#TODO ptam se jestli nekdo kdo neexistuje ma pristup. Pozor na vyjimku, mel bych vratit rovnou false.
#TODO Lze pridat privilege do principal a naopak? test na to by byl peknej :)

#Usage example. Also very good source of information are test cases.
puts "start"
$:.unshift("../../eXistAPI/lib")
require 'eXistAPI'    #must require 'eXistAPI' to comunicated with eXist-db

#create instance of ExistAPI
@db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")    
@col_path = "/db/test_acl/"         #sets the collection where you want to have ACL in db
@src_files_path = "./src_files/"    #path to source files
if(@db.existscollection?(@col_path))
  @db.remove_collection(@col_path) #Deleting old ACL from db
end
report = true
@my_acl = RubyACL.new("my_acl", @db, @col_path, @src_files_path, report)

#it's good to create some principals at the begging
@my_acl.create_principal("Sheldon")  
@my_acl.create_principal("Leonard")   
@my_acl.create_principal("Rajesh")   
@my_acl.create_principal("Howarda")   
@my_acl.create_principal("Penny")   
@my_acl.create_principal("Kripkie") 

#Besides given privileges you can create your owns
@my_acl.create_privilege("WATCH")   
@my_acl.create_privilege("SIT")

#You can create resource object and get id of it.
resource_id = @my_acl.create_resource_object("mov", "/Movies", "Sheldon")
@my_acl.create_resource_object("couch", "/livingroom", "Sheldon")
@my_acl.create_resource_object("seat", "/livingroom/couch/Sheldon's_spot", "Sheldon")

#Now we have everything we need to create the rule.
#Lets see what we must hand over
#1) One individual or group that    (principal)
#2) will or won't have access       (access type = {allow, deny})
#3) to do something with            (privilege)
#4) which type of                   (resource type)
#5) resource.                       (resource object)
#6) And if we needs to grand all this to children of resource.  (grant to children)
@my_acl.create_ace("Sheldon", "allow", "DELETE", "mov", "/Movies", true)
@my_acl.create_ace("Sheldon", "allow", "SIT", "seat", "/livingroom/couch/Sheldon's_spot")


#You can easily check e.g. if Penny may delete all movies.
@my_acl.check("Penny", "DELETE", "mov", "/Movies")

#Next method call returns deny
@my_acl.check("Penny", "SIT", "seat", "/livingroom/couch/Sheldon's_spot")

#You can create group and immidiatly insert members or do it later.
@my_acl.create_group("4th_floor", ["ALL"], ["Sheldon","Leonard","Penny"])
#Here are other possible ways of creating group
#@my_acl.create_group("4th_floor")
#@my_acl.create_group("4th_floor", ["ALL"])
#
#Create access control entry with group as principal.
ace_id = @my_acl.create_ace("4th_floor", "allow", "WATCH", "mov", "/Movies/*")

#You can show all privileges connected with principal
perm = @my_acl.show_permissions_for("Penny")
puts perm

#EXCEPTION EXAMPLE
@my_acl.create_group("Scientists")    #you must create group before you use it
@my_acl.add_membership_principal("Sheldon", ["Scientists"])

#You also must create privileges before you use them
@my_acl.create_privilege("TALK")
@my_acl.create_privilege("COMUNICATE")
#You can gather privileges in treelike structure
@my_acl.add_membership_privilege("TALK", ["COMUNICATE"])

#You can delete membership of principal and privilege, 
#ace, principal, privilege, resource object, if exists. 
#Otherwise you will get exception
@my_acl.del_membership_principal("Sheldon", ["Scientists"])
@my_acl.del_membership_privilege("TALK", ["COMUNICATE"])
@my_acl.delete_ace(ace_id)
@my_acl.delete_principal("Kripkie")
@my_acl.delete_privilege("SIT")
@my_acl.delete_res_object("couch", "/livingroom")
@my_acl.delete_res_object_by_id(resource_id)

@my_acl.create_resource_object("mov", "/Movies", "Sheldon") #create again for demonstration purposes
#You can rename principal, privilege and change every part of resource object.
@my_acl.rename_principal("Kripkie", "Kwipkie")
@my_acl.rename_privilege("TALK", "CHAT")
@my_acl.change_of_res_ob_address("mov", "/Movies", "/Films")
@my_acl.change_of_res_ob_owner("mov", "/Films", "Leonard")
@my_acl.change_res_ob_type("mov", "/Films", "motion picture")

#You can save or load ACL
#@my_acl.save('C:\\storage')
#RubyACL.load(@db, "C:\\backup")

#You can rename ACL
@my_acl.rename("my_beloved_acl")

puts "finished"
