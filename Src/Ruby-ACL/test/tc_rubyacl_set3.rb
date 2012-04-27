#This set of tests are focused on methods modifing ACL Objects 
#(principals, privileges, resource objects).

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("../eXistAPI/lib")

require 'eXistAPI'
require 'test/unit'
require 'ruby-acl.rb'

class TestRubyACL < Test::Unit::TestCase
  def test_set3_00a_add_membership_principal
    test_set2_01_create_principal
    test_set2_02a_create_group
    @test_acl.add_membership_principal("labut", ['ptaciHejno'])
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"labut\"]/membership/mgroup[@idref=\"ptaciHejno\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
    assert_raise (RubyACLException){
      @test_acl.add_membership_principal("labut", ['NotExisting'])
    }
    assert_raise (RubyACLException){
      @test_acl.add_membership_principal("NotExisting", ['ptaciHejno'])
    }
  end
  
  def test_set3_00b_add_membership_principal
    test_set2_01_create_principal
    test_set2_02a_create_group
    assert_raise ( RubyACLException ) {
      @test_acl.add_membership_principal("ptaciHejno", ['labut'])
    }
  end
  
  def test_set3_01_add_membership_privilege
    test_set2_03_create_privilege('KUTALET')
    assert_raise ( RubyACLException ) {
      @test_acl.add_membership_privilege("STAT", ['KUTALET'])
    }
    @test_acl.create_privilege("STAT")
    @test_acl.add_membership_privilege("STAT", ['KUTALET'])
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"STAT\"]/membership/mgroup[@idref=\"KUTALET\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(1, hits)
    assert_raise ( RubyACLException ) {
      @test_acl.add_membership_privilege("STAT", ['NotExisting'])
    }
  end
  
  def test_set3_02_del_membership_principal
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
    assert_raise ( RubyACLException ) {
      @test_acl.del_membership_principal("NotExisting", ['Users'])
    }    
    assert_raise ( RubyACLException ) {
      @test_acl.del_membership_principal("Klubicko", ['NotExisting'])
    }
  end
  
  def test_set3_03_del_membership_privilege
    test_set3_01_add_membership_privilege
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
  
  def test_set3_04a_delete_principal(name = 'blabol')
    test_set2_01_create_principal(name)
    @test_acl.delete_principal(name)
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  #checks if is deleted references of membership
  def test_set3_04b_delete_group()
    group = "test_group"
    user = "test_user"
    
    @test_acl.create_principal(user)
    @test_acl.create_group(group, ["ALL"], [user])
    
    query = "doc(\"#{@col_path}Principals.xml\")//node()[@id=\"#{user}\"]/membership/mgroup[@idref=\"#{group}\"]"
    #puts query
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(1, hits)
    
    @test_acl.delete_principal(group)
    
    query = "doc(\"#{@col_path}Principals.xml\")//node()[@id=\"#{user}\"]/membership/mgroup[@idref=\"#{group}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  #checks if ACE is deleted
  def test_set3_04c_delete_principal()
    user = "test_user"
    @test_acl.create_principal(user)
    id = @test_acl.create_ace(user, "allow", "SELECT", "test", "/db/temporary/testsource")
    
    @test_acl.delete_principal(user)
    query = "doc(\"#{@col_path}acl.xml\")//node()[@id=\"#{id}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_set3_05a_delete_privilege(name = 'KECAT')
    test_set2_03_create_privilege(name)
    @test_acl.delete_privilege(name)
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"#{name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_set3_05b_delete_privilege()
    user = "test_user"
    priv = "test_privilege"
    @test_acl.create_privilege(priv)
    id = @test_acl.create_ace(user, "allow", priv, "test", "/db/temporary/testsource")
    
    @test_acl.delete_privilege(priv)
    query = "doc(\"#{@col_path}acl.xml\")//node()[@id=\"#{id}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_set3_06a_delete_res_object(type = 'Les', address = 'cernocerny')
    #r = ResourceObject.new(@db, @col_path)
    #puts r.find_res_ob(type, address)
    id_created = test_set2_04_create_resource_object(type, address)
    #puts r.find_res_ob(type, address)
    id_del = @test_acl.delete_res_object(type, address)
    assert(id_created, id_del)
    #puts "res ID #{id_del}"
    query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id_del}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits, "Method \"delete_res_object\" is not working properly.")
  end
  
#Checks if ACE mentioning resOb is deleted too
  def test_set3_06b_delete_res_object()
    user = "test_user"
    priv = "test_privilege"
    res_ob_type = "test"
    res_ob_adr = "/db/temporary/testsource"
    
    @test_acl.create_principal(user)
    @test_acl.create_resource_object(res_ob_type, res_ob_adr, user)
    id = @test_acl.create_ace(user, "allow", priv, res_ob_type, res_ob_adr)
    
    @test_acl.delete_res_object(res_ob_type, res_ob_adr)
    query = "doc(\"#{@col_path}acl.xml\")//node()[@id=\"#{id}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_set3_07_del_ace(prin_name = 'Klubicko', acc_type = 'allow', priv_name = 'ALL_PRIVILEGES', res_ob_type = 'Kosik', res_ob_adrs = 'Pleteny')
    id_created = test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    id_deleted = @test_acl.delete_ace(id_created)
    assert_equal(id_created, id_deleted)
    query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id_deleted}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_set3_08_rename_principal()
    old_name = "Klubicko"
    new_name = "Kosticka"
    query = "doc(\"#{@col_path}Principals.xml\")//node()[@id=\"#{new_name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
    @test_acl.rename_principal(old_name, new_name)
    query = "doc(\"#{@col_path}Principals.xml\")//node()[@id=\"#{new_name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(1, hits)
  end
  
  def test_set3_09_rename_privilege()
    old_name = "SELECT"
    new_name = "ZOBRAZIT"
    query = "doc(\"#{@col_path}Privileges.xml\")//node()[@id=\"#{new_name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
    @test_acl.rename_privilege(old_name, new_name)
    query = "doc(\"#{@col_path}Privileges.xml\")//node()[@id=\"#{new_name}\"]"
    #puts query
    handle = @db.execute_query(query)
    #@db.retrieve(handle, 0)
    hits = @db.get_hits(handle)
    assert_equal(1, hits)
  end
    
  def test_set3_12_change_res_ob_type()
    type = "Pleteny_kosik"
    adr = "/v_obyvaku/na_skrini"
    new_type = "Prouteny_kosik"
    res = ResourceObject.new(@db, @col_path)
    id = res.find_res_ob(type, adr)
    @test_acl.change_res_ob_type(type, adr, new_type)
    query = "doc(\"#{@col_path}ResourceObjects.xml\")//node()[@id=\"#{id}\"]/type/text()"
    handle = @db.execute_query(query)
    res = @db.retrieve(handle, 0)
    assert_equal(new_type, res)
  end
  
  def test_set3_13_change_of_res_ob_address()
    type = "Pleteny_kosik"
    adr = "/v_obyvaku/na_skrini"
    new_adr = "/ve_sklepe"
    res = ResourceObject.new(@db, @col_path)
    id = res.find_res_ob(type, adr)
    @test_acl.change_of_res_ob_address(type, adr, new_adr)
    query = "doc(\"#{@col_path}ResourceObjects.xml\")//node()[@id=\"#{id}\"]/address/text()"
    handle = @db.execute_query(query)
    assert_equal(new_adr, @db.retrieve(handle, 0))
  end
  
  def test_set3_14_change_of_res_ob_owner()
    type = "Pleteny_kosik"
    adr = "/v_obyvaku/na_skrini"
    new_owner = "Prouteny_kosik"
    res = ResourceObject.new(@db, @col_path)
    id = res.find_res_ob(type, adr)
    @test_acl.change_of_res_ob_owner(type, adr, new_owner)
    query = "doc(\"#{@col_path}ResourceObjects.xml\")//node()[@id=\"#{id}\"]/owner/string(@idref)"
    handle = @db.execute_query(query)
    assert_equal(new_owner, @db.retrieve(handle, 0))
  end
end
