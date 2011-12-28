$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'Ruby-acl'
require 'privilege'

class TestRubyacl < Test::Unit::TestCase
  @@acl=Ruby_acl.new('testACL')
  def test_temp_init
    flunk "TODO: Write test"
  end
  
  def test_01create_default_privileges
    assert(@@acl.privileges.size == Privilege.default_privileges.size*2,"Created privileges in Ruby_acl should be twice more then default privilges in Privileges")
  end
  
  def test_02to_s
    flunk "TODO: Write test"
  end
  
  def test_03check
    @@acl.resource_objects.push(ResourceObject.new(nil,nil,'houby'))
    @@acl.add_ace('sirljan', 'allow', 'write', 'houby')
    assert_equal(true,@@acl.check('sirljan', 'allow', 'write', 'houby'))
    assert_equal(false,@@acl.check('mraztom', 'allow', 'write', 'houby'))
    assert_equal(false,@@acl.check('sirljan', 'deny', 'write', 'houby'))
    assert_equal(false,@@acl.check('sirljan', 'allow', 'read', 'houby'))
    assert_equal(false,@@acl.check('sirljan', 'allow', 'read', 'ptak'))
    assert_raise do#(PrincpalDoesntExist) do
      @@acl.check('notexists', 'allow', 'read', 'ptak')
    end
    assert_raise do #(AccesstypeDoesntExist) do
      @@acl.check('sirljan', 'notexists', 'read', 'ptak')
    end
    assert_raise do #(OperationDoesntExist) do
      @@acl.check('sirljan', 'allow', 'notexists', 'ptak')
    end
    assert_raise do #(ResourceobjectDoesntExist) do
      @@acl.check('sirljan', 'allow', 'read', 'notexists')
    end
    
  end
  
  def test_04find_all_groups_with_membership_of_principal
    flunk "TODO: Write test"
  end
  
  def test_05find_aces
    flunk "TODO: Write test"
  end
  
  def test_06save
    flunk "TODO: Write test"
  end
  
  def test_07load
    flunk "TODO: Write test"
  end
  
  def test_08principal
    flunk "TODO: Write test"
  end
  
  def test_09privilege
    flunk "TODO: Write test"
  end
  
  def test_10resource_object
    flunk "TODO: Write test"
  end
  
  def test_11add_ace
    flunk "TODO: Write test"
  end
  
  def test_12del_ace
    flunk "TODO: Write test"
  end
  
  def test_13mod_ace
    flunk "TODO: Write test"
  end
  
  def test_14create_group
    flunk "TODO: Write test"
  end
end
