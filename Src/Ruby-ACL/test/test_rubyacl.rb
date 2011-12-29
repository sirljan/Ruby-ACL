$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'Ruby-acl'
require 'privilege'
require 'principal'
require 'resource_object'


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
    @@acl.create_group('slavisti')
    @@acl.create_group('spartani')
    @@acl.add_membership('mraztom', ['slavisti','spartani'])
    assert_equal(['slavisti','spartani'],@@acl.find_all_groups_with_membership_of_principal('mraztom',@@acl.principals))
  end
  
  def test_05find_aces
    aces = []
    aces.push(@@acl.add_ace('mraztom', 'allow', 'write', 'houby'))
    aces.push(@@acl.add_ace('spartani', 'allow', 'write', 'kocka'))
    assert_equal(aces, find_aces('mraztom'))
  end
  
  def test_06save
    @@acl.save('SavedACL')
    acl2 = Ruby_acl.load('SavedACL')
    assert_equal(@@acl, acl2)
  end
  
  def test_07load
    @@acl.save('SavedACL')
    acl2 = Ruby_acl.load('SavedACL')
    assert_equal(@@acl, acl2)
  end
  
  def test_08find_principal
    name=''
    assert_raise do
      find_principal(name)
    end
    p = Principal.new('nobody')
    assert_equal(p,find_principal('nobody'))
  end
  
  def test_09find_privilege
    p = Privilege.new('allow', 'sort')
    assert_equal(p,find_privilege('allow', 'sort'))
  end
  
  def test_10find_resource_object
    res = ResourceObject.new(nil, nil, 'wc')
    assert_equal(res,find_resource_object('wc'))
  end
  
  def test_11add_ace
    @@acl.create_principal('man')
    ace=@@acl.add_ace('man', 'allow', 'write', 'ryba')
    assert_equal(@@acl.aces.last,ace)
  end
  
  def test_12del_ace
    @@acl.create_principal('man2')
    ace_before = @@acl.aces
    ace=@@acl.add_ace('man2', 'deny', 'read', 'ptak')
    assert_equal(@@acl.aces.last,ace)
    del_ace(ace.id)
    assert_equal(ace_before, @@acl.aces)
  end
  
  def test_13mod_ace
    flunk "TODO: Write test"
  end
  
  def test_14create_group
    group = @@acl.create_group('superGroup')
    assert_equal(group,@@acl.find_principal('superGroup'))
  end
end
