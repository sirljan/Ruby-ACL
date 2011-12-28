
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'principal'
require 'group'

class TestPrincipal < Test::Unit::TestCase
  @@count = 0
  def setup
    @prin = Principal.new('testPrincipal')
    
    @@count += 1
  end
  
  def test_01prin_counter
    assert_equal(@@count, Principal.prin_counter)
  end
  
  def test_02add_membership
    Group.new('testGroup')
    @@count += 1
    @prin.add_membership('testGroup')
    assert_equal(['testGroup'],@prin.member_of)
  end
  
  def test_03change_name
    @prin.change_name('Hanicka')
    assert_equal('Hanicka',@prin.name)
  end
  
  def test_04to_s
    assert_equal("#{@@count-1} \t testPrincipal \t #{[]}",@prin.to_s)
  end
end
