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
  
  def find_parent(prin_name,index, zanoreni)
    puts "\t"*zanoreni + "#{index} ----------------"
    index+=1
    prins = []
    query = "//node()[@id=\"#{prin_name}\"]/membership/*/string(@idref)"
    handle = @connector.execute_query(query)
    hits = @connector.get_hits(handle)
    puts "\t"*zanoreni + "hits #{hits}"
    puts "\t"*zanoreni + query
    hits.times { 
      |i|
      prin = @connector.retrieve(handle, i)
      if(prin=="")
        next      #for unknown reason exist returns 1 empty hit even any exists e.g. //node()[@id="all"]/membership/*/string(@idref)
      end
      prins.push(prin)
      puts "\t"*zanoreni + prin
      prins = prins + find_parent(prin,index,zanoreni+1)
    }
    
    return prins
  end
  
  def check(prin_name, priv_name, res_ob_id)
    
    #prins = find_parent(prin_name)
    
    query = <<END 
for $ace in /acl/ACEs/ace
where $ace/principal/@idref="#{prin_name}" and $ace/privilege/@idref="#{priv_name}" and $ace/resourceObject/@idref="#{res_ob_id}"
return $ace/accessType/text()
END
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
      expr = "/acl/ACEs/descendant::*[@id=\"#{ace_id}\"]"
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
        expr_single = "/acl/Principals/descendant::*[@id=\"#{prin_name}\"]/membership"
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
          expr = "/acl/Principals/descendant::*[@id=\"#{prin_name}\"]/membership/group[@idref=\"#{group}\"]"
          #expr = "/acl/Principals/descendant::*[@id=\"#{prin_name}\"]/membership/group[@xlink:href=\"acl.xml##{group}\"]"
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
      expr = "/acl/Principals/descendant::*[@id=\"#{name}\"]"
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
        expr_single = "/acl/Privileges/descendant::*[@id=\"#{priv_name}\"]/membership"
        #puts expr_single
        @connector.update_insert(expr, "into", expr_single)
      end
    else
      puts "Privilege \"#{priv_name}\" does not exist."
    end
  end
  
  def del_priv(name)
    if(Privilege.exists?(name, @connector))
      expr = "/acl/Privileges/descendant::*[@id=\"#{name}\"]"
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
mojeacl.add_priv_memship('STAT', ["KUTALET"])
#puts "Deleting parent privilege"
#mojeacl.del_priv("STAT")
puts "Adding ACE"
mojeacl.add_ace("Houby", "allow", "RUST", "963")
#puts "Deleting ACE"
#mojeacl.del_ace(987)
puts "Checking ACE "+'("Houby", "RUST", "963")'
if(mojeacl.check("Houby", "RUST", "963"))
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
puts "find parent"
puts mojeacl.find_parent("sirljan",0,0)
puts "Saving acl from db to local file."
mojeacl.save("pokus")






#mojeacl.add_ace('silvejan', 'allow', 'write', 'ryba')
#
#puts mojeacl.check('silvejan', 'allow', 'write', 'ryba')

