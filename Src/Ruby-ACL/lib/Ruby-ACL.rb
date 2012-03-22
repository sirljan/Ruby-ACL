$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/lib")
require 'principal'
require 'accessor'
require 'group'
require 'privilege'
require 'resource_object'
require 'ace'
require 'main'


class RubyACL
  def initialize(name, connector, colpath = "/db/acl/")
    @name = name
    @connector = connector
    @colpath = colpath
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
      puts "Collection doesn't exist. Creating collection."
      @connector.createcollection(@colpath)
      col = @connector.getcollection(@colpath)
    end
    sfs = src_files(col)
    if(sfs != [])
      fns=""
      sfs.each { |sf| 
        fns = fns + '"'+sf+'"' 
        if(sf != sfs.last())
          fns = fns+", "
        end
      }
      puts "Source file(s) #{fns} doesn't/don't exist. Creating new source file(s)."
      for sfile in sfs
        xmlfile = File.read(sfile)
        @connector.storeresource(xmlfile, @colpath + sfile)
      end
      col = @connector.getcollection(@colpath)
    end
    if(col.name == @colpath && src_files(col) == [])
      puts "Collection and source files exist."
      doc = col['acl.xml']
      doc.to_s
    else
      puts "Collection and source files doesn't/don't exist."
    end
  end
  
  def src_files(col)   #return array of files that are not present in acl collection
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
  
  def find_parent(id)
    ids = []
    query = "//node()[@id=\"#{id}\"]/membership/*/string(@idref)"
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    hits.times { 
      |i|
      id_ref = @connector.retrieve(handle, i)
      if(id_ref=="")
        next      #for unknown reason exist returns 1 empty hit even any exists e.g. //node()[@id="all"]/membership/*/string(@idref)
      end
      ids = ids | [id_ref] | find_parent(id_ref)   #unite arrays
    }
    return ids
  end
  
  protected

  public              # follow public methods

  def to_s
    puts "Name = #{@name} \n\n"
    col = @connector.getcollection(@colpath)
    doc = col['acl.xml']
    doc.content
  end
  
  def save(path)
    col = @connector.getcollection(@colpath)    
    docs = col.docs()
    docs.each{|doc| 
      document = col[doc] 
      doc = "BU_"+doc
      filename = path + doc
      f = File.new(filename, 'w')
      f.puts(document.content)    
      f.close
    }
  end
  
  def RubyACL.load(filename, connector, colpath = "/db/acl/")
    connector.remove_collection(colpath)
    connector.createcollection(colpath)
    #osetrit nacitani souboru - vyjimka pri neexistujicim souboru
    xmlfile = File.read(filename)
    connector.storeresource(xmlfile, colpath + "acl.xml")
    handle = connector.execute_query("/acl/string(@aclname)")
    name = connector.retrieve(handle, 0)
    newacl=RubyACL.new(name, connector, colpath)
    return newacl

    #puts @name
  end
  
  def check(prin_name, priv_name, res_ob_id)
    
    prins = [prin_name] + find_parent(prin_name)
    privs = [priv_name] + find_parent(priv_name)
    
    query = <<END 
for $ace in /acl/ace
where $ace/principal/@idref="#{prin_name}" and $ace/privilege/@idref="#{priv_name}" and $ace/resourceObject/@idref="#{res_ob_id}"
return $ace/accessType/text()
END
    query = <<END 
for $ace in /acl/ace
where (
END
    for prin in prins
      query += "$ace/principal/@idref=\"#{prin}\""
      if(prin != prins.last)
        query+=" or "
      else
        query+=") "
      end
    end
    
    query += " and ("
    for priv in privs
      query += "$ace/privilege/@idref=\"#{priv}\""
      if(priv != privs.last)
        query+=" or "
      else
        query+=") "
      end
    end
    query += "return $ace/accessType/text()"
    #puts query
    
    handle = @connector.execute_query(query)
    
    hits = @connector.get_hits(handle)
    #    puts "hits #{hits}"
    if(hits>0)
      if(hits==1)
        res = @connector.retrieve(handle, 0)
        if(res=="allow")
          return true
        elsif(res=="deny")
          return false
        end
      else
        puts "Not implemented yet. Sorry :("
      end
      
    else
      puts "Required rule (#{prin_name},#{priv_name},#{res_ob_id}) does not exist. Access denied."
      return false
    end
    
  end
  
  def add_ace(prin_name, acc_type, priv_name, res_ob_id)
    Ace.new(prin_name, acc_type, priv_name, res_ob_id, @connector)
  end
  
  def del_ace(ace_id)
    if(Ace.exists?(ace_id, @connector))
      expr = "/acl/descendant::*[@id=\"#{ace_id}\"]"
      @connector.update_delete(expr)
    else
      puts "ACE with id \"#{ace_id}\" does not exist."
    end
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
      if(Principal.exists?(name, @connector))
        puts "New principal \"#{name}\" created."
      else
        puts "Principal \"#{name}\" was not able to create."
      end
    end
    add_membership(name, groups, true)
  end
  
  def create_group(name, member_of = [], members = [])    # members can be groups or individuals; check if it the name already exist. or if groups and members exist at all
    bool=true
    if(name == nil || name == '')
      puts "Name is empty."
      bool=false
    end
    if(Group.exists?(name, @connector))
      puts "Group \"#{name}\" already exist. Please choose different name."
      bool=false
    end
  
    if(bool)
      Group.new(name, @connector)
      if(Group.exists?(name, @connector))
        puts "New group \"#{name}\" created."
      else
        puts "Group \"#{name}\" was not able to create."
      end
    end
    if(member_of.length > 0)
      add_membership(name, member_of, true)
    end
    if(members.length > 0)
      for each in members
        add_membership(each, [name], true)
      end
    end
    
  end
  
  def add_membership(prin_name, groups = [], prin_exists=false) #adds prin_name into group(s); if you know prin exists set true for prin_exists
    if(prin_exists || Principal.exists?(prin_name, @connector))
      #puts "podminka"
      #puts prin_name
      for group in groups
        if(!Group.exists?(group, @connector))
          puts "WARNING: Group \"#{group}\" does not exist."
        end
        expr = "<group idref=\"#{group}\"/>"
        #expr = '<group xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="acl.xml#'+"#{group}"+"\"/>"
        expr_single = "/Principals/descendant::*[@id=\"#{prin_name}\"]/membership"
        #puts expr_single
        @connector.update_insert(expr, "into", expr_single)
      end
    else
      puts "Principal with name \"#{prin_name}\" does not exist."
    end
  end
  
  def del_membership(prin_name, groups) #deletes prin_name from group(s)
    if(Principal.exists?(prin_name, @connector))
      for group in groups
        if(Group.exists?(group, @connector))
          expr = "/Principals/descendant::*[@id=\"#{prin_name}\"]/membership/group[@idref=\"#{group}\"]"
          #expr = "/Principals/descendant::*[@id=\"#{prin_name}\"]/membership/group[@xlink:href=\"acl.xml##{group}\"]"
          @connector.update_delete(expr)
        else
          puts "WARNING: Can not delete membership in \"#{group}\". Group \"#{group}\" does not exist."
        end

      end
    else
      puts "Principal with name \"#{prin_name}\" does not exist."
    end
  end
  
  def del_prin(name)
    #smazat i vsechny ResourceObjets 
    if(Principal.exists?(name, @connector))
      expr = "/Principals/descendant::*[@id=\"#{name}\"]"
      @connector.update_delete(expr)
    else
      puts "Principal with name \"#{name}\" does not exist."
    end
  end
  
  def create_priv(name, member_of = [])
    bool=true
    if(name == nil || name == '')
      puts "Name is empty."
      bool=false
    end
    if(Privilege.exists?(name, @connector))
      puts "Privilege \"#{name}\" already exist. Please choose different name."
      bool=false
    end
  
    if(bool)
      Privilege.new(name, @connector)
      if(Privilege.exists?(name, @connector))
        puts "New privilege \"#{name}\" created."
      else
        puts "Privilege \"#{name}\" was not able to create."
      end
    end
    if(member_of.length > 0)
      add_priv_memship(name, member_of, true)
    end
    
  end
  
  def add_priv_memship(priv_name, parent_priv = [], priv_exists=false)
    #osetrit aby neslo pridat pod allow pravidlo deny a naopak
    if(priv_exists || Privilege.exists?(priv_name, @connector))
      #puts "podminka"
      #puts priv_name
      for ppriv in parent_priv
        if(Privilege.exists?(ppriv, @connector))
          puts "WARNING: Privilege \"#{ppriv}\" does not exist."
        end
        expr = "<privilege idref=\"#{ppriv}\"/>"
        expr_single = "/Privileges/descendant::*[@id=\"#{priv_name}\"]/membership"
        #puts expr_single
        @connector.update_insert(expr, "into", expr_single)
      end
    else
      puts "Privilege \"#{priv_name}\" does not exist."
    end
  end
  
  def del_priv(name)
    if(Privilege.exists?(name, @connector))
      expr = "/Privileges/descendant::*[@id=\"#{name}\"]"
      #puts expr
      @connector.update_delete(expr)
    else
      puts "Privilege with name \"#{name}\" does not exist."
    end
  end
  
end

$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/eXistAPI/lib")
require "eXistAPI"

db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")

#mojeacl = RubyACL.load("pokus.xml", db, "/db/acl/")

puts "Deleting old ACL from db for testing purposes."
db.remove_collection("/db/acl/")
puts 'Creating new acl'
mojeacl = RubyACL.new("prvniacl", db)
puts "to_s. JESTLI TO PORAD NEFUNGUJE, TAK TO KOUKEJ DODELAT!!!"
mojeacl.to_s
puts "Adding membership"
mojeacl.add_membership('Developers', ['Users'])
groups = ['Administrators', 'Users', 'Developers', 'Houbari']
puts "Creating new group"
mojeacl.create_group('labutiHejno')
puts "Adding membership"
mojeacl.add_membership('labutiHejno', ['Users'])
puts "Creating new principal"
mojeacl.create_principal("labut", ['labutiHejno'])
#mojeacl.create_principal("ara")
mojeacl.add_membership("labut", groups)
puts "Deleting membership"
mojeacl.del_membership('labut',['Users'])
puts "Deleting membership"
mojeacl.del_membership('Developers',['Administrators'])
puts "Deleting individual"
mojeacl.del_prin('Klubicko')
puts "Deleting group"
mojeacl.del_prin('Kosik')
puts "Creating privilege"
mojeacl.create_priv('KUTALET')
puts "Creating privilege"
mojeacl.create_priv('STAT')
puts "Adding membership to privilege"
mojeacl.add_priv_memship('STAT', ["KUTALET"])
puts "Deleting parent privilege"
mojeacl.del_priv("STAT")
puts "Adding ACE"
mojeacl.add_ace("Houby", "allow", "RUST", "963")
puts "Deleting ACE"
mojeacl.del_ace("a987")
puts "Checking ACE "+'("Houby", "SELECT", "a963")'
if(mojeacl.check("Houby", "SELECT", "a963"))
  puts "Access was allowed"
else
  puts "Access was denied"
end
puts "Checking ACE - group " + '("sirljan", "SELECT", "852")'
if(mojeacl.check("sirljan", "SELECT", "852"))
  puts "Access was allowed"
else
  puts "Access was denied"
end
puts "Saving acl from db to local file."
mojeacl.save("./backup/")
 





#mojeacl.add_ace('silvejan', 'allow', 'write', 'ryba')
#
#puts mojeacl.check('silvejan', 'allow', 'write', 'ryba')

