#This set of tests are focused only to RubyACL.check method.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("../eXistAPI/lib")

require 'eXistAPI'
require 'test/unit'
require 'ruby-acl.rb'

class TestRubyACL < Test::Unit::TestCase
#  def test_18a_check1()    #simple test, ask for check if ace exists
#    prin_name = 'sirljan'
#    acc_type = 'allow'
#    priv_name = 'SELECT'
#    res_ob_type = 'Pleteny_kosik'
#    res_ob_adrs='/v_obyvaku/na_skrini'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(true, access)
#  end
#
#  def test_18b_check1()    #simple test, ask for check if ace doesnt exists
#    prin_name = 'sirljan'
#    priv_name = 'SELECT'
#    res_ob_type = 'Kosik'
#    res_ob_adrs='Pleteny'
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(false, access)
#  end
#
#  def test_19_check()    #if owner and deny
#    prin_name = 'sirljan'
#    acc_type = 'deny'
#    priv_name = 'SELECT'
#    res_ob_type = 'doc'
#    res_ob_adrs='/db/cities/cities.xml'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    #puts "access #{access}"
#    assert_equal(true, access)
#  end
#
#  def test_20_check()    #Add privilege to group. Checking if member has privilege too.
#    prin_name = 'Users'
#    acc_type = 'allow'
#    priv_name = 'SELECT'
#    res_ob_type = 'doc'
#    res_ob_adrs='/db/cities/cities.xml'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    access = @test_acl.check('sirljan', priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(true, access)
#  end
#
#  def test_21_check()    #Allow for group, deny for principal in group
#    prin_name = 'Users'
#    acc_type = 'allow'
#    priv_name = 'SELECT'
#    res_ob_type = 'doc'
#    res_ob_adrs='/db/cities/cities.xml'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    prin_name = 'sirljan'
#    acc_type = 'deny'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(false, access)
#  end
#
#  def test_22_check()    #Deny for group, allow for principal in group
#    prin_name = 'Users'
#    acc_type = 'deny'
#    priv_name = 'SELECT'
#    res_ob_type = 'doc'
#    res_ob_adrs='/db/cities/cities.xml'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    prin_name = 'sirljan'
#    acc_type = 'allow'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(true, access)
#  end
#
#  #Allow for ALL_PRIVILEGES, deny one. 
#  #Check if one is checked as deny and some other checked as allow.
#  def test_23_check()    
#    prin_name = 'Klubicko'
#    acc_type = 'allow'
#    priv_name = 'ALL_PRIVILEGES'
#    res_ob_type = 'doc'
#    res_ob_adrs='/db/temp'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    prin_name = 'Klubicko'
#    acc_type = 'deny'
#    priv_name = 'ALTER'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    priv_name = 'ALTER'
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(false, access)
#    priv_name = 'DROP'
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(true, access)
#  end
#
#  #Allow for parent resource, deny for descendent.
#  #Checks if explicit deny stronger than inherited allow.
#  def test_24_check()    
#    prin_name = 'Klubicko'
#    acc_type = 'allow'
#    priv_name = 'SELECT'
#    res_ob_type = 'doc'
#    res_ob_adrs='/db/temp'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    acc_type = 'deny'
#    res_ob_adrs='/db/temp/test'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)    
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(false, access)
#    
#    res_ob_adrs='/db/temp'
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(true, access)
#  end
#  
#  #Allow for parent resource.
#  #Checks if descendent resource has inherited permision.
#  def test_25_check()    
#    prin_name = 'Klubicko'
#    acc_type = 'allow'
#    priv_name = 'SELECT'
#    res_ob_type = 'doc'
#    res_ob_adrs='/db/temp'
#    test_09_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
#    res_ob_adrs='/db/temp/test'    
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(true, access)
#    
#    res_ob_adrs='/db/temp'
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(true, access)
#    
#    res_ob_adrs='/db/temp/test/hokus'
#    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
#    assert_equal(true, access)
#  end
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
end
