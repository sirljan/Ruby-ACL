#TODO test coverige
#TODO testy v rake http://guides.rubygems.org/make-your-own-gem/#writing-tests


$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("../eXistAPI/lib")
#$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/lib")
#puts $:

#TODO odkomentovat
require 'simplecov'
SimpleCov.start

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
    @src_files_path = "./lib/src_files/"
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
  
#  def test_01_create_acl
#    #TODO bez existujici koleckce, s existujici kolekci, s kolekci a par souborama, se vsim
#    collection = @db.getcollection(@col_path)
#    assert_equal(true, @db.existscollection?(@col_path))  # Collection must existc
#    # In collecition must be acl.xml, Principals.xml, Privileges.xml, ResourceObjects.xml
#    assert_equal(['acl.xml','Principals.xml','Privileges.xml','ResourceObjects.xml'], collection.docs)
#  end
#  
#  def test_02_save
#    @save_path = "./test/test_backup/"
#    @test_acl.save(@save_path, true)
#    @save_path = @save_path + Date.today.to_s + "/"
#    assert_not_nil(File.size?(@save_path+'acl.xml'))
#    assert_not_nil(File.size?(@save_path+'Principals.xml'))
#    assert_not_nil(File.size?(@save_path+'Privileges.xml'))
#    assert_not_nil(File.size?(@save_path+'ResourceObjects.xml'))
#  end
#  
#  def test_03_load
#    handle = @db.execute_query("doc(\"#{@col_path}acl.xml\")/acl/string(@aclname)")
#    acl_name = @db.retrieve(handle, 0)
#    test_02_save
#    test_loaded_acl = RubyACL.load(@db, "/db/loaded_acl/", @save_path)
#    assert_equal(acl_name, test_loaded_acl.name)
#    if(@db.existscollection?("/db/loaded_acl/"))
#      @db.remove_collection("/db/loaded_acl/") #Deleting loaded ACL from db after test_load
#    end
#  end
#  
#  def test_04_setname(new_name = "other_name")
#    @test_acl.setname(new_name)
#    query = "doc(\"#{@col_path}acl.xml\")/acl[@aclname=\"#{new_name}\"]"
#    handle = @db.execute_query(query)
#    hits = @db.get_hits(handle)
#    assert_equal(1, hits)
#  end
#  
#  def test_05_create_principal(name = 'labut')
#    #TODO with same name, group with same name
#    @test_acl.create_principal(name)
#    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
#    #puts "query #{query}"
#    handle = @db.execute_query(query)
#    hits = @db.get_hits(handle)
#    #puts "hits #{hits}"
#    assert_equal(1, hits)
#  end
#  
#  def test_06_create_group(name = 'ptaciHejno')
#    #TODO with same name, group with same name
#    @test_acl.create_group(name)
#    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
#    #puts "query #{query}"
#    handle = @db.execute_query(query)
#    hits = @db.get_hits(handle)
#    #puts "hits #{hits}"
#    assert_equal(1, hits)
#  end
#  
#  def test_07_create_privilege(name = "LITAT")
#    #TODO with same name, group with same name
#    @test_acl.create_privilege(name)
#    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"#{name}\"]"
#    #puts "query #{query}"
#    handle = @db.execute_query(query)
#    hits = @db.get_hits(handle)
#    #puts "hits #{hits}"
#    assert_equal(1, hits)
#  end
#  
#  def test_08_create_resource_object(type = 'Rybnik', address = '/Rozmberk', owner = 'sirljan')
#    #TODO create identical
#    #TODO check owner
#    id = @test_acl.create_resource_object(type, address, owner)
#    query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id}\"]"
#    #puts "query #{query}"
#    handle = @db.execute_query(query)
#    hits = @db.get_hits(handle)
#    #puts "hits #{hits}"
#    assert_equal(1, hits)
#    return id
#  end
#  
  def test_09_create_ace(prin_name = 'sirljan', acc_type = 'allow', priv_name = 'SELECT', res_ob_type = 'doc', res_ob_adrs='/db/cities/cities.xml')
    id = @test_acl.create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    query = "doc(\"#{@col_path}acl.xml\")//Aces/descendant::*[@id=\"#{id}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
    return id
  end
#
#
#def test_10_add_membership_principal
#  #TODO vytvori i kdyz skupina neexistuje. Nevytvori/vyhodi error kdyz principal neexistuje
#  test_05_create_principal
#  test_06_create_group
#  @test_acl.add_membership_principal("labut", ['ptaciHejno'])
#  query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"labut\"]/membership/mgroup[@idref=\"ptaciHejno\"]"
#  #puts "query #{query}"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  #puts "hits #{hits}"
#  assert_equal(1, hits)
#end
#
#def test_11_add_membership_privilege
#  #TODO vyjimku na prirazeni membership skupiny, ktera neexistuje.
#  test_07_create_privilege('KUTALET')
#  assert_raise ( RubyACLException ) {@test_acl.add_membership_privilege("STAT", ['KUTALET'])}
#  @test_acl.create_privilege("STAT")
#  @test_acl.add_membership_privilege("STAT", ['KUTALET'])
#  query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"STAT\"]/membership/mgroup[@idref=\"KUTALET\"]"
#  #puts "query #{query}"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  #puts "hits #{hits}"
#  assert_equal(1, hits)
#end
#
#def test_12_del_membership_principal
#  #TODO neco na vyjimku.
#  @test_acl.del_membership_principal("Klubicko", ['Users'])
#  query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"Klubicko\"]"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  #puts "hits #{hits}"
#  assert_equal(1, hits)
#  query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"Klubicko\"]/membership/mgroup[@idref=\"Users\"]"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  assert_equal(0, hits)
#end
#
#def test_13_del_membership_privilege
#  test_11_add_membership_privilege
#  @test_acl.del_membership_privilege("STAT", ['KUTALET'])
#  query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"STAT\"]"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  assert_equal(1, hits)     #confirms STAT exists
#  query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"STAT\"]/membership/mgroup[@idref=\"KUTALET\"]"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  assert_equal(0, hits)     #confirms STAT is not in member of privilege KUTALET
#end
#
#def test_14_delete_principal(name = 'blabol')
#  test_05_create_principal(name)
#  @test_acl.delete_principal(name)
#  query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  assert_equal(0, hits)
#end
#
#def test_15_delete_privilege(name = 'KECAT')
#  test_07_create_privilege(name)
#  @test_acl.delete_privilege(name)
#  query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"#{name}\"]"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  assert_equal(0, hits)
#end
#
#def test_16_delete_res_object(type = 'Les', address = 'cernocerny')
#  #r = ResourceObject.new(@db, @col_path)
#  #puts r.find_res_ob(type, address)
#  id_created = test_08_create_resource_object(type, address)
#  #puts r.find_res_ob(type, address)
#  id_del = @test_acl.delete_res_object(type, address)
#  assert(id_created, id_del)
#  #puts "res ID #{id_del}"
#  query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id_del}\"]"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  assert_equal(0, hits, "Method \"delete_res_object\" is not working properly.")
#end
#
#def test_17_del_ace(prin_name = 'Klubicko', acc_type = 'allow', priv_name = 'ALL_PRIVILEGES', res_ob_type = 'Kosik', res_ob_adrs = 'Pleteny')
#  id_created = test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  id_deleted = @test_acl.delete_ace(id_created)
#  assert_equal(id_created, id_deleted)
#  query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id_deleted}\"]"
#  handle = @db.execute_query(query)
#  hits = @db.get_hits(handle)
#  assert_equal(0, hits)
#end
#
#def test_18a_check1()    #simple test, ask for check if ace exists
#  prin_name = 'sirljan'
#  acc_type = 'allow'
#  priv_name = 'SELECT'
#  res_ob_type = 'Kosik'
#  res_ob_adrs='Pleteny'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(true, access)
#end
#
#def test_18b_check1()    #simple test, ask for check if ace doesnt exists
#  prin_name = 'sirljan'
#  priv_name = 'SELECT'
#  res_ob_type = 'Kosik'
#  res_ob_adrs='Pleteny'
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(false, access)
#end
#
#def test_19_check()    #if owner and deny
#  prin_name = 'sirljan'
#  acc_type = 'deny'
#  priv_name = 'SELECT'
#  res_ob_type = 'doc'
#  res_ob_adrs='/db/cities/cities.xml'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  #puts "access #{access}"
#  assert_equal(true, access)
#end
#
#def test_20_check()    #Add privilege to group. Checking if member has privilege too.
#  prin_name = 'Users'
#  acc_type = 'allow'
#  priv_name = 'SELECT'
#  res_ob_type = 'doc'
#  res_ob_adrs='/db/cities/cities.xml'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  access = @test_acl.check('sirljan', priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(true, access)
#end
#
#def test_21_check()    #Allow for group, deny for principal in group
#  prin_name = 'Users'
#  acc_type = 'allow'
#  priv_name = 'SELECT'
#  res_ob_type = 'doc'
#  res_ob_adrs='/db/cities/cities.xml'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  prin_name = 'sirljan'
#  acc_type = 'deny'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(false, access)
#end
#
#def test_22_check()    #Deny for group, allow for principal in group
#  prin_name = 'Users'
#  acc_type = 'deny'
#  priv_name = 'SELECT'
#  res_ob_type = 'doc'
#  res_ob_adrs='/db/cities/cities.xml'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  prin_name = 'sirljan'
#  acc_type = 'allow'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(true, access)
#end
#
##Allow for ALL_PRIVILEGES, deny one. 
##Check if one is checked as deny and some other checked as allow.
#def test_23_check()    
#  prin_name = 'Klubicko'
#  acc_type = 'allow'
#  priv_name = 'ALL_PRIVILEGES'
#  res_ob_type = 'doc'
#  res_ob_adrs='/db/temp'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  prin_name = 'Klubicko'
#  acc_type = 'deny'
#  priv_name = 'ALTER'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  priv_name = 'ALTER'
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(false, access)
#  priv_name = 'DROP'
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(true, access)
#end
#
##Allow for parent resource, deny for descendent.
##Checks if explicit deny stronger than inherited allow.
#def test_24_check()    
#  prin_name = 'Klubicko'
#  acc_type = 'allow'
#  priv_name = 'SELECT'
#  res_ob_type = 'doc'
#  res_ob_adrs='/db/temp'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#  acc_type = 'deny'
#  res_ob_adrs='/db/temp/test'
#  test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)    
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(false, access)
#    
#  res_ob_adrs='/db/temp'
#  access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#  assert_equal(true, access)
#  #  end
#  
  #Allow for parent resource.
  #Checks if descendent resource has inherited permision.
  def test_25_check()    
    prin_name = 'Klubicko'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp'
    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    res_ob_adrs='/db/temp/test'    
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
    
    res_ob_adrs='/db/temp'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
    
    res_ob_adrs='/db/temp/test/hokus'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end
#  
#  #deny and allow for same principal
#  def test_26_check()
#    prin_name = 'Klubicko'
#    acc_type = 'allow'
#    priv_name = 'SELECT'
#    res_ob_type = 'doc'
#    res_ob_adrs='/db/temp'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    acc_type = 'deny'    
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(false, access)
#  end
  
  
  
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