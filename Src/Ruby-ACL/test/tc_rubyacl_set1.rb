#This set of tests are focused on methods closed to ACL.
#Such as creating ACL, saving it, loading, set new name of ACL ...
$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("../eXistAPI/lib")

require 'eXistAPI'
require 'test/unit'
require 'ruby-acl.rb'

class TestRubyACL < Test::Unit::TestCase
  
  def setup
    @db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
    @col_path = "/db/test_acl/"
    @src_files_path = "./lib/src_files/"
    if(@db.existscollection?(@col_path))
      @db.remove_collection(@col_path) #Deleting old ACL from db for testing purposes.
    end
    @test_acl = RubyACL.new("test_acl", @db, @col_path, @src_files_path)
  end

  def test_set1_01_create_acl
    #TODO bez existujici koleckce, s existujici kolekci, s kolekci a par souborama, se vsim
    collection = @db.getcollection(@col_path)
    assert_equal(true, @db.existscollection?(@col_path))  # Collection must existc
    # In collecition must be acl.xml, Principals.xml, Privileges.xml, ResourceObjects.xml
    assert_equal(['acl.xml','Principals.xml','Privileges.xml','ResourceObjects.xml'], collection.docs)
  end
  
  def test_set1_02_save
    @save_path = "./test/test_backup/"
    @test_acl.save(@save_path, true)
    @save_path = @save_path + Date.today.to_s + "/"
    assert_not_nil(File.size?(@save_path+'acl.xml'))
    assert_not_nil(File.size?(@save_path+'Principals.xml'))
    assert_not_nil(File.size?(@save_path+'Privileges.xml'))
    assert_not_nil(File.size?(@save_path+'ResourceObjects.xml'))
  end
  
  def test_set1_03_load
    handle = @db.execute_query("doc(\"#{@col_path}acl.xml\")/acl/string(@aclname)")
    acl_name = @db.retrieve(handle, 0)
    test_set1_02_save
    test_loaded_acl = RubyACL.load(@db, "/db/loaded_acl/", @save_path)
    assert_equal(acl_name, test_loaded_acl.name)
    if(@db.existscollection?("/db/loaded_acl/"))
      @db.remove_collection("/db/loaded_acl/") #Deleting loaded ACL from db after test_load
    end
  end
  
  def test_set1_04_setname(new_name = "other_name")
    @test_acl.setname(new_name)
    query = "doc(\"#{@col_path}acl.xml\")/acl[@aclname=\"#{new_name}\"]"
    handle = @db.execute_query(query)
    hits = @db.get_hits(handle)
    assert_equal(1, hits)
  end
end
