$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'exist_a_p_i'

class TestExistAPI < Test::Unit::TestCase
  def setup
    @api = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
    @col_path = "/db/testcollection"
    @cities = "doc(\"#{@col_path}/cities.xml\")"
    @api.createcollection(@col_path)
    source = File.read("./cities.xml")
    @api.storeresource(source, @col_path+"/cities.xml")
  end
  
  def teardown()
    @api.remove_collection(@col_path)
  end
  
  def test_00_create_connection()
    #Test if connect is established
    assert(@api.existscollection?(@col_path))
  end
  
  def test_01_createcollection
    path = "/db/testcollection/newcollection"
    @api.createcollection(path)
    assert(@api.existscollection?(path))
  end
  
  def test_02_getcollection
    col = @api.getcollection(@col_path)
    assert_not_nil(col)
  end
  
  def test_03_existscollection?()
    assert(@api.existscollection?(@col_path))
  end
  
  def test_04_remove_collection()
    @api.remove_collection(@col_path)
    assert(!@api.existscollection?(@col_path))
  end
  
  def test_05_storeresource
    handle = @api.execute_query("doc(\"#{@col_path}/cities.xml\")/cities")
    hits = @api.get_hits(handle)
    assert_equal(1, hits)
  end
  
  def test_06_execute_query
    handle = @api.execute_query("doc(\"#{@col_path}/cities.xml\")//city[population>1000000]/name/text()")
    hits = @api.get_hits(handle)
    assert_equal(2, hits)
  end
  
  def test_07_retrieve
    handle = @api.execute_query("doc(\"#{@col_path}/cities.xml\")//city[population>1000000]/name/text()")
    hits = @api.get_hits(handle)
    retrieved_cities = Array.new
    for hit in hits
      city = @api.retrieve(handle, hit)
      retrieved_cities.push(city)
    end
    cities = ["Los Angeles","Praha"]
    cities.sort!
    retrieved_cities.sort!
    assert_equal(cities, retrieved_cities)
  end
  
  def test_08_get_hits
    handle = @api.execute_query("#{@cities}//city[population>1000000]/name/text()")
    hits = @api.get_hits(handle)
    assert_equal(2, hits)
  end 
  
  def test_09_update_insert
    expr = "#{@cities}//city[name=\"Praha\"]"
    pos = "into"
    expr_single = "<capital>yes</capital>"
    @api.update_insert(expr, pos, expr_single)
    
    handle = @api.execute_query("#{@cities}//city[capital=\"yes\"]")
    hits = @api.get_hits(handle)
    assert_eqaul(1, hits)
  end
  
  def test_10_update_replace
    expr = "#{@cities}//city[name=\"Praha\"]"
    pos = "into"
    expr_single = "<capital_of>Czech Republic</capital_of>"
    @api.update_replace(expr, pos, expr_single)
    handle = @api.execute_query("#{@cities}//city[capital_of=\"Czech Republic\"]")
    hits = @api.get_hits(handle)
    assert_eqaul(1, hits)
  end
  
end
