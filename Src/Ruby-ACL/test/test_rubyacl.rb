# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/eXistAPI/lib")

require 'eXistAPI'
require 'test/unit'
require 'ruby-acl.rb'

class Test_RubyACL < Test::Unit::TestCase
  def setup
    @db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
    @col_path = "/db/test_acl/"
    @src_files_path = "./src_files/"
    if(@db.existscollection?(@col_path))
      @db.remove_collection(@col_path) #Deleting old ACL from db for testing purposes.
    end
    @test_acl = RubyACL.new("test_acl", @db, @col_path, @src_files_path)
  end
  
  def test_create_acl
    #TODO bez existujici koleckce, s existujici kolekci, s kolekci a par souborama, se vsim
    collection = @db.getcollection(@col_path)
    assert_equal(true, @db.existscollection?(@col_path))  # Collection must existc
    # In collecition must be acl.xml, Principals.xml, Privileges.xml, ResourceObjects.xml
    assert_equal(['acl.xml','Principals.xml','Privileges.xml','ResourceObjects.xml'], collection.docs)
  end
  
  def test_save
    @save_path = "./test_backup/"
    
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
  end
  
  def test_create_principal
    #TODO with same name, group with same name
    @test_acl.create_principal("labut")
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"labut\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_create_group
    #TODO with same name, group with same name
    @test_acl.create_group('ptaciHejno')
    query = "doc(\"#{@col_path}Principals.xml\")/Principals/descendant::*[@id=\"ptaciHejno\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
  
  def test_create_privilege
    #TODO with same name, group with same name
    @test_acl.create_privilege("LITAT")
    query = "doc(\"#{@col_path}Privileges.xml\")/Privileges/descendant::*[@id=\"LITAT\"]"
    #puts "query #{query}"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    #puts "hits #{hits}"
    assert_equal(1, hits)
  end
#  
#  def test_add_ace
#    flunk "TODO"
#  end
#  
#  def test_del_ace
#    flunk "TODO"
#  end
  
  
  #  def test_missing_src_files
  #    #flunk "TODO"
  #    @db.remove_collection(@col_path)
  #    xmlfile = File.read(@src_files_path + "acl.xml")
  #    @connector.storeresource(xmlfile, @col_path + "acl.xml")
  #    assert_not_equal([],missing_src_files(@col_path))
  #  end
  
end
