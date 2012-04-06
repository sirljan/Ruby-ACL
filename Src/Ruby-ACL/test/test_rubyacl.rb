#TODO test coverige

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/eXistAPI/lib")
$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/lib")

require 'eXistAPI'
require 'test/unit'
require 'ruby-acl.rb'

class TestRubyACL < Test::Unit::TestCase
  #@@runs = 0
  def setup
    #@@runs += 1
    #puts @@runs
    @db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
    @col_path = "/db/test_acl/"
    @src_files_path = "C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/lib/src_files/"
    if(@db.existscollection?(@col_path))
      @db.remove_collection(@col_path) #Deleting old ACL from db for testing purposes.
    end
    @test_acl = RubyACL.new("test_acl", @db, @col_path, @src_files_path)
  end
  
  #  def teardown
  #    #TODO delete loaded acl and remove last line in test_load
  #    if(@db.existscollection?("/db/loaded_acl/"))
  #      @db.remove_collection("/db/loaded_acl/") #Deleting loaded ACL from db after test_load
  #    end
  #  end
  
  def test_create_acl
    #TODO bez existujici koleckce, s existujici kolekci, s kolekci a par souborama, se vsim
    collection = @db.getcollection(@col_path)
    assert_equal(true, @db.existscollection?(@col_path))  # Collection must existc
    # In collecition must be acl.xml, Principals.xml, Privileges.xml, ResourceObjects.xml
    assert_equal(['acl.xml','Principals.xml','Privileges.xml','ResourceObjects.xml'], collection.docs)
  end
  
  def test_save
    @save_path = "C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/test/test_backup/"
    @test_acl.save(@save_path, true)
    @save_path = @save_path + Date.today.to_s + "/"
    assert_not_nil(File.size?(@save_path+'acl.xml'))
    assert_not_nil(File.size?(@save_path+'Principals.xml'))
    assert_not_nil(File.size?(@save_path+'Privileges.xml'))
    assert_not_nil(File.size?(@save_path+'ResourceObjects.xml'))
  end
  
  def test_load
    handle = @db.execute_query("doc(\"#{@col_path}acl.xml\")/acl/string(@aclname)")
    acl_name = @db.retrieve(handle, 0)
    test_save
    test_loaded_acl = RubyACL.load(@db, "/db/loaded_acl/", @save_path)
    assert_equal(acl_name, test_loaded_acl.name)
    if(@db.existscollection?("/db/loaded_acl/"))
      @db.remove_collection("/db/loaded_acl/") #Deleting loaded ACL from db after test_load
    end
  end
  
  def test_setname(new_name = "other_name")
    @test_acl.setname(new_name)
    query = "doc(\"#{@col_path}acl.xml\")/acl[@aclname=\"#{new_name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(1, hits)
  end
  
  def test_create_principal(name = 'labut')
    #TODO with same name, group with same name
    @test_acl.create_principal(name)
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_create_group(name = 'ptaciHejno')
    #TODO with same name, group with same name
    @test_acl.create_group(name)
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_create_privilege(name = "LITAT")
    #TODO with same name, group with same name
    @test_acl.create_privilege(name)
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"#{name}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_create_resource_object(type = 'Rybnik', address = '/Rozmberk')
    #TODO create identical
    id = @test_acl.create_resource_object(type, address)
    query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
    return id
  end
  
  def test_create_ace(prin_name = 'sirljan', acc_type = 'allow', priv_name = 'SELECT', res_ob_type = 'doc', res_ob_adrs='/db/cities/cities.xml')
    id = @test_acl.create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    query = "doc(\"#{@col_path}acl.xml\")//Aces/descendant::*[@id=\"#{id}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_add_membership_principal
    #TODO vytvori i kdyz skupina neexistuje. Nevytvori/vyhodi error kdyz principal neexistuje
    test_create_principal
    test_create_group
    @test_acl.add_membership_principal("labut", ['ptaciHejno'])
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"labut\"]/membership/mgroup[@idref=\"ptaciHejno\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_add_membership_privilege
    assert_raise ( RubyACLException ) {@test_acl.add_membership_privilege("STAT", ['KUTALET'])}
    @test_acl.create_privilege("STAT")
    @test_acl.add_membership_privilege("STAT", ['KUTALET'])
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"STAT\"]/membership/mgroup[@idref=\"KUTALET\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_del_membership_principal
    #TODO neco na vyjimku.
    @test_acl.del_membership_principal("Klubicko", ['Users'])
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"Klubicko\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"Klubicko\"]/membership/mgroup[@idref=\"Users\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_del_membership_privilege
    test_add_membership_privilege
    @test_acl.del_membership_privilege("STAT", ['KUTALET'])
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"STAT\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(1, hits)     #confirms STAT exists
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"STAT\"]/membership/mgroup[@idref=\"KUTALET\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)     #confirms STAT is not in member of privilege KUTALET
  end
  
  def test_delete_principal(name = 'blabol')
    test_create_principal(name)
    @test_acl.delete_principal(name)
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_delete_privilege(name = 'KECAT')
    test_create_privilege(name)
    @test_acl.delete_privilege(name)
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"#{name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end

  def test_delete_res_object(type = 'Les', address = 'cernocerny')
    #r = ResourceObject.new(@db, @col_path)
    #puts r.find_res_ob(type, address)
    id_created = test_create_resource_object(type, address)
    #puts r.find_res_ob(type, address)
    id_del = @test_acl.delete_res_object(type, address)
    assert(id_created, id_del)
    #puts "res ID #{id_del}"
    query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id_del}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits, "Method \"delete_res_object\" is not working properly.")
  end
    
  def test_del_ace(prin_name = 'Klubicko', acc_type = 'allow', priv_name = 'ALL_PRIVILEGES', res_ob_type = 'Kosik', res_ob_adrs = 'Pleteny')
    id_created = test_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    id_deleted = @test_acl.delete_ace(id_created)
    assert_equal(id_created, id_deleted)
    query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id_deleted}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_zcheck1a()    
    prin_name = 'sirljan'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/cities/cities.xml'
    test_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end
  
  def test_zcheck1b()    
    prin_name = 'sirljan'
    acc_type = 'deny'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/cities/cities.xml'
    test_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  end
  
  def test_zcheck2()    #Add privilege to group. Checking if member has privilege too.
    prin_name = 'Users'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/cities/cities.xml'
    test_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check('sirljan', priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end
  
  def test_zcheck3()
    prin_name = 'Users'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/cities/cities.xml'
    test_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    prin_name = 'sirljan'
    acc_type = 'deny'
    test_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check('sirljan', priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  end
  
  #  def test_missing_src_files
  #    #flunk "TODO"
  #    @db.remove_collection(@col_path)
  #    xmlfile = File.read(@src_files_path + "acl.xml")
  #    @connector.storeresource(xmlfile, @col_path + "acl.xml")
  #    assert_not_equal([],missing_src_files(@col_path))
  #  end
  
end

#runner = Test::Unit::UI::GTK::TestRunner
#Console::TestRunner 
#runner.run(TestRubyACL)