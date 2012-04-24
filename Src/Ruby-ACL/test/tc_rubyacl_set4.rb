#This set of tests are focused only to RubyACL.check method.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift("../eXistAPI/lib")

require 'eXistAPI'
require 'test/unit'
require 'ruby-acl.rb'

class TestRubyACL < Test::Unit::TestCase
  
  def test_set3_08a_check1()    #simple test, ask for check if ace exists
    prin_name = 'sirljan'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'Pleteny_kosik'
    res_ob_adrs='/v_obyvaku/na_skrini'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end

  def test_set3_08b_check1()    #simple test, ask for check if ace doesnt exists
    prin_name = 'sirljan'
    priv_name = 'SELECT'
    res_ob_type = 'Pleteny_kosik'
    res_ob_adrs='/v_obyvaku/na_skrini'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  end

  def test_set3_09_check()    #if owner and deny
    prin_name = 'Klubicko'
    acc_type = 'deny'
    priv_name = 'SELECT'
    res_ob_type = 'Pleteny_kosik'
    res_ob_adrs='/v_obyvaku/na_skrini'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    #puts "access #{access}"
    assert_equal(true, access)
  end

  def test_set3_10_check()    #Add privilege to group. Checking if member has privilege too.
    prin_name = 'Users'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/cities/cities.xml'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check('sirljan', priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end

  def test_set3_11_check()    #Allow for group, deny for principal in group
    prin_name = 'Users'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/cities/cities.xml'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    prin_name = 'sirljan'
    acc_type = 'deny'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  end

  def test_set3_12_check()    #Deny for group, allow for principal in group
    prin_name = 'Users'
    acc_type = 'deny'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/cities/cities.xml'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    prin_name = 'sirljan'
    acc_type = 'allow'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end

  #Allow for ALL_PRIVILEGES, deny one. 
  #Check if one is checked as deny and some other checked as allow.
  def test_set3_13_check()    
    prin_name = 'Klubicko'
    acc_type = 'allow'
    priv_name = 'ALL_PRIVILEGES'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    prin_name = 'Klubicko'
    acc_type = 'deny'
    priv_name = 'ALTER'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    priv_name = 'ALTER'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
    priv_name = 'DROP'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end
  #
  #Allow for parent resource, deny for descendent.
  #Checks if explicit deny stronger than inherited allow.
  def test_set3_14_check()    
    prin_name = 'Klubicko'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    acc_type = 'deny'
    res_ob_adrs='/db/temp/test'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)    
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  
    res_ob_adrs='/db/temp'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end

  #Allow for parent resource.
  #Checks if descendent resource has NOT inherited permision.
  def test_set3_15_check()    
    prin_name = 'Klubicko'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
  
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  
    res_ob_adrs='/db/temp/test'    
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  
    res_ob_adrs='/db/temp/test/hokus'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  end

  #deny and allow for same principal
  def test_set3_16_check()
    prin_name = 'Klubicko'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    acc_type = 'deny'    
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  end

  #Allow for children resources.
  #Checks if descendent resource has inherited permision.
  def test_set3_17_check()    
    prin_name = 'nikdo'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp/*'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    prin_name = 'Klubicko'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp/*'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    
    res_ob_adrs='/db/temp'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
    
    res_ob_adrs='/db/temp/test'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
    
    res_ob_adrs='/db/temp/test/hokus'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
  end
  
  #Deny for children resources.
  #Checks if descendent resource has inherited permision.
  def test_set3_17_check()    
    prin_name = 'nikdo'
    acc_type = 'deny'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp/*'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    prin_name = 'Klubicko'
    acc_type = 'deny'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp/*'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    prin_name = 'Klubicko'
    acc_type = 'allow'
    priv_name = 'SELECT'
    res_ob_type = 'doc'
    res_ob_adrs='/db/temp'
    test_set2_05_create_ace(prin_name, acc_type, priv_name, res_ob_type, res_ob_adrs)
    
    res_ob_adrs='/db/temp'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(true, access)
    
    res_ob_adrs='/db/temp/test'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
    
    res_ob_adrs='/db/temp/test/hokus'
    access = @test_acl.check(prin_name, priv_name, res_ob_type, res_ob_adrs)
    assert_equal(false, access)
  end
end
