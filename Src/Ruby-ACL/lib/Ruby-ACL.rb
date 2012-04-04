$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/lib")
require 'ACL_Object'
require 'Principal'
require 'individual'
require 'group'
require 'privilege'
require 'resource_object'
require 'ace'
require 'main'
require 'date'
require 'rubyacl_exception'

class RubyACL
  
  # common access methods
  attr_reader :name
  attr_reader :col_path
  
  def initialize(name, connector, colpath = "/db/acl/", src_files_path = "./src_files/")
    @name = name #TODO vloz jmeno do acl documentu
    @connector = connector
    if(colpath[-1] != "/")
      colpath += "/"
    end
    @col_path = colpath
    @src_files_path = src_files_path
    @prin = Principal.new(@connector, @col_path)
    @indi = Individual.new(@connector, @col_path)
    @group = Group.new(@connector, @col_path)
    @priv = Privilege.new(@connector, @col_path)
    @res_obj = ResourceObject.new(@connector, @col_path)
    @ace = Ace.new(@connector, @col_path)
    create_acl_in_db()
  end
  
  private   # private methods follow
  

  
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
      #puts "Source file(s) #{missing_files} doesn't/don't exist. Creating new source file(s)."  
      for sfile in sfs
        #TODO osetrit nacitani souboru - vyjimka pri neexistujicim souboru
        xmlfile = File.read(@src_files_path + sfile)
        @connector.storeresource(xmlfile, @col_path + sfile)
      end
      col = @connector.getcollection(@col_path)
    end
    
    if(col.name == @col_path && missing_src_files(col) == [])
      #puts "Collection and source files exist."
    else
      #puts "Collection and source files doesn't/don't exist."
    end
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
  
  def parent(adr)
    if(adr[-1] == "/")
      adr = adr[0..-2]
    end
    pos = adr.rindex("/")
    adr = adr[0..pos]
    return adr
  end
  
  def find_parent(id, doc)   #finds membership parrent, e.g. dog's parrent is mammal
    query = "#{doc}//node()[@id=\"#{id}\"]/membership/*/string(@idref)"
    ids = []
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    hits.times {
      |i|
      id_ref = @connector.retrieve(handle, i)
      if(id_ref=="")
        next      #for unknown reason eXist returns 1 empty hit even any exists therefore unite is skipped (e.g. //node()[@id="all"]/membership/*/string(@idref)
      end
      ids = ids | [id_ref] | find_parent(id_ref, doc)   #unite arrays
    }
    return ids
  end
  
  def find_res_ob_parent(res_ob_type, res_ob_adrs)   #finds membership parrent, e.g. dog's parrent is mammal
    query = "#{@res_obj.doc}//node()[(type=\"#{res_ob_type}\") and(address=\"#{res_ob_adrs}\")]/membership/*/string(@idref)"
    ids = []
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    hits.times {
      |i|
      id_ref = @connector.retrieve(handle, i)
      if(id_ref=="")
        next      #for unknown reason eXist returns 1 empty hit even any exists therefore unite is skipped (e.g. //node()[@id="all"]/membership/*/string(@idref)
      end
      res_ob_adrs = parent(res_ob_adrs)
      ids = ids | [id_ref] | find_res_ob_parent(res_ob_type, res_ob_adrs)   #unite arrays
    }
    return ids
  end
  
  protected

  public              # follow public methods

  def setname(new_name)
    query = "update value doc(\"#{@col_path}acl.xml\")/acl/@aclname with \"#{new_name}\""
    @connector.execute_query(query)
    query = "doc(\"#{@col_path}acl.xml\")/acl/string(@aclname)"
    handle = @connector.execute_query(query)
    if(new_name != @connector.retrieve(handle, 0))
      raise RubyACL_Exception.new("Failed to set new name.", 1), 
        "Failed to set new name.", caller
    end
  end
  
  def to_s
    puts "Name = #{@name} \n\n"
    col = @connector.getcollection(@col_path)
    doc = col['acl.xml']
    doc.content
  end
  
  def save(path, date = false)
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
  end
  
  def RubyACL.load(connector, colpath = "/db/acl/", src_files_path)
    xmlfile = File.read(src_files_path+"acl.xml") #TODO vyjimka?
    startindex = xmlfile.index('"', xmlfile.index("aclname="))
    endindex = xmlfile.index('"', startindex+1)
    name = xmlfile[startindex+1..endindex-1]
    newacl = RubyACL.new(name, connector, colpath, src_files_path)
    return newacl
  end
  
  def check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    
    prins = [prin_name] + find_parent(prin_name, @prin.doc)    #creates the set of principals {wanted principal and all groups wanted principal is member of}
    privs = [priv_name] + find_parent(priv_name, @priv.doc)    #creates the set of privileges {wanted privilege and all privileges wanted privilege is member of}
    res_obs = [@res_obj.find_res_ob(res_ob_type, res_ob_adrs)] + find_res_ob_parent(res_ob_type, res_ob_adrs)
    
    query = <<END 
for $ace in #{@ace.doc}//Ace
where (
END
    for prin in prins
      query += "$ace/Principal/@idref=\"#{prin}\""
      if(prin != prins.last)
        query+=" or "
      else
        query+=") "
      end
    end
    
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
      if(priv != privs.last)
        query+=" or "
      else
        query+=") "
      end
    end
    
    query += "return $ace/accessType/text()"
    #puts query
    
    handle = @connector.execute_query(query)
    #puts "handle nil? #{handle.nil?}"
    hits = @connector.get_hits(handle)
    #    puts "hits #{hits}"
    if(hits > 0)
      if(hits == 1)
        res = @connector.retrieve(handle, 0)
        if(res == "allow")
          return true
        elsif(res == "deny")
          return false
        end
      else
        puts "Not implemented yet. Sorry :("
        #TODO Vice zaznamu
      end
      
    else
      puts "Required rule (#{prin_name}, #{priv_name}, #{res_ob_type}, #{res_ob_adrs}) does not exist. Access denied."
      return false
    end
    
  end
  
  def create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    res_ob_id = @res_obj.find_res_ob(res_ob_type, res_ob_adrs)
    if(res_ob_id == nil)
      res_ob_id = @res_obj.create_new(res_ob_type, res_ob_adrs)
    end
    @ace.create_new(prin_name, acc_type, priv_name, res_ob_id)
  end
  
  def create_principal(name, groups = [])
    @indi.create_new(name, groups)
  end
  
  def create_group(name, member_of = [], members = [])    # members can be groups or individuals; check if it the name already exist. or if groups and members exist at all
    @group.create_new(name, member_of, members)    
  end
  
  def create_privilege(name, member_of = [])
    @priv.create_new(name, member_of)
  end
  
  def create_resource_object(type, address)
    #puts "type #{type} add #{address}"
    id = @res_obj.create_new(type, address)
    return id
  end
  
  def add_membership_principal(name, groups, existance = false) #adds principal into group(s); if you know prin exists set true for prin_exists
    @prin.add_membership(name, groups, existance)
  end
  
  def add_membership_privilege (name, groups, existance = false) #adds privilege into group(s); if you know prin exists set true for prin_exists
    @priv.add_membership(name, groups, existance)
  end
  
  def del_membership_principal(prin_name, groups) #deletes prin_name from group(s)
    @prin.del_membership(prin_name, groups)
  end
  
  def del_membership_privilege(priv_name, groups) #deletes prin_name from group(s)
    @priv.del_membership(priv_name, groups)
  end
  
  def delete_principal(name)
    @prin.delete(name)
  end
  
  def delete_privilege(name)
    @priv.delete(name)
  end
  
  def delete_res_object(type, address)
    res_ob_id = @res_obj.find_res_ob(type, address)
    @res_obj.delete(res_ob_id)
    return res_ob_id
  end
  
  def delete_res_object_by_id(id)
    @res_obj.delete(id)
  end
  
  def delete_ace(ace_id)
    @ace.delete(ace_id)
  end

  
end

#$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/eXistAPI/lib")
#require "eXistAPI"
#
#db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
#puts "Deleting old ACL from db for testing purposes."
#db.remove_collection("/db/acl/")
#puts 'Creating new acl'
#mojeacl = RubyACL.new("prvniacl", db)
#
#puts "Creating new principal"
#mojeacl.create_principal("labut")
#
#puts "Creating new group"
#mojeacl.create_group('labutiHejno')
#
#puts "Adding membership"
#mojeacl.add_membership_principal('Developers', ['Users'])
#
#puts "Creating privilege"
#mojeacl.create_privilege('KUTALET')
#puts "Creating privilege"
#mojeacl.create_privilege('STAT')
#puts "Adding membership to privilege"
#mojeacl.add_membership_privilege('STAT', ["KUTALET"])
#puts "Deleting privilege"
#mojeacl.del_membership_privilege('STAT', ["KUTALET"])


##mojeacl = RubyACL.load("pokus.xml", db, "/db/acl/")
#


#puts "to_s. JESTLI TO PORAD NEFUNGUJE, TAK TO KOUKEJ DODELAT!!!"
#mojeacl.to_s

#groups = ['Administrators', 'Users', 'Developers', 'Houbari']

#puts "Adding membership"
#mojeacl.add_membership('labutiHejno', ['Users'])

##mojeacl.create_principal("ara")
#mojeacl.add_membership("labut", groups)
#puts "Deleting membership"
#mojeacl.del_membership('labut',['Users'])
#puts "Deleting membership"
#mojeacl.del_membership('Developers',['Administrators'])
#puts "Deleting individual"
#mojeacl.del_prin('Klubicko')
#puts "Deleting group"
#mojeacl.del_prin('Kosik')


#puts "Deleting parent privilege"
#mojeacl.del_priv("STAT")
#puts "Adding ACE"
#mojeacl.add_ace("Houby", "allow", "RUST", "a963")
#puts "Deleting ACE"
#mojeacl.del_ace("a987")
#puts "Checking ACE "+'("Houby", "SELECT", "a963")'
#if(mojeacl.check("Houby", "SELECT", "a963"))
#  puts "Access was allowed"
#else
#  puts "Access was denied"
#end
#puts "Checking ACE - group " + '("sirljan", "SELECT", "a852")'
#if(mojeacl.check("sirljan", "SELECT", "a852"))
#  puts "Access was allowed"
#else
#  puts "Access was denied"
#end
#puts "Saving acl from db to local file."
#mojeacl.save("./backup/")