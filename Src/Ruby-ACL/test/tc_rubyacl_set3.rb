#This set of tests are focused on methods modifing ACL Objects 
#(principals, privileges, resource objects).

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("../eXistAPI/lib")

require 'eXistAPI'
require 'test/unit'
require 'ruby-acl.rb'

class TestRubyACL < Test::Unit::TestCase
  def test_set3_00_add_membership_principal
    #TODO vytvori i kdyz skupina neexistuje. Nevytvori/vyhodi error kdyz principal neexistuje
    test_set2_01_create_principal
    test_set2_02_create_group
    @test_acl.add_membership_principal("labut", ['ptaciHejno'])
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"labut\"]/membership/mgroup[@idref=\"ptaciHejno\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_set3_01_add_membership_privilege
    #TODO vyjimku na prirazeni membership skupiny, ktera neexistuje.
    test_set2_03_create_privilege('KUTALET')
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
  
  def test_set3_02_del_membership_principal
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
  
  def test_set3_04_delete_principal(name = 'blabol')
    test_set2_01_create_principal(name)
    @test_acl.delete_principal(name)
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_set3_05_delete_privilege(name = 'KECAT')
    test_set2_03_create_privilege(name)
    @test_acl.delete_privilege(name)
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"#{name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_set3_06_delete_res_object(type = 'Les', address = 'cernocerny')
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
  
  def test_set3_07_del_ace(prin_name = 'Klubicko', acc_type = 'allow', priv_name = 'ALL_PRIVILEGES', res_ob_type = 'Kosik', res_ob_adrs = 'Pleteny')
    id_created = test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    id_deleted = @test_acl.delete_ace(id_created)
    assert_equal(id_created, id_deleted)
    query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id_deleted}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(0, hits)
  end
end
