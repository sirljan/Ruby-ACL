#This set of tests are focused on methods that create ACL Objects 
#(principals, privileges, resource objects).

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("../eXistAPI/lib")

require 'eXistAPI'
require 'test/unit'
require 'ruby-acl.rb'

class TestRubyACL < Test::Unit::TestCase
  def test_set2_01_create_principal(name = 'labut')
    #TODO with same name, group with same name
    @test_acl.create_principal(name)
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_set2_02_create_group(name = 'ptaciHejno')
    #TODO with same name, group with same name
    @test_acl.create_group(name)
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"#{name}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_set2_03_create_privilege(name = "LITAT")
    #TODO with same name, group with same name
    @test_acl.create_privilege(name)
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"#{name}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_set2_04_create_resource_object(type = 'Rybnik', address = '/Rozmberk', owner = 'sirljan')
    #TODO create identical
    #TODO check owner
    id = @test_acl.create_resource_object(type, address, owner)
    query = "doc(\"#{@col_path}ResourceObjects.xml\")/ResourceObjects/descendant::*[@id=\"#{id}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
    return id
  end
  
  def test_set2_05_create_ace(prin_name = 'sirljan', acc_type = 'allow', priv_name = 'SELECT', res_ob_type = 'doc', res_ob_adrs='/db/cities/cities.xml')
    id = @test_acl.create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    query = "doc(\"#{@col_path}acl.xml\")//Aces/descendant::*[@id=\"#{id}\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
    return id
  end
  
  #if different acctype will raise exception
  def test_set2_06_create_ace()
    prin_name = 'Misa'
    acc_type = 'smrdi'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/cities/cities.xml'
    assert_raise RubyACLException do
      @test_acl.create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    end
  end
end
