$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'eXistAPI'

class TestExistAPI < Test::Unit::TestCase
  def setup
    @api = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")
    @col_path = "/db/testcollection"
    @cities = "doc(\"#{@col_path}/cities.xml\")"
    #@api.remove_collection(@col_path)
    @api.createcollection(@col_path)
    source = File.read("./test/cities.xml")
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
    path = "db/testcollection/newcollection2"
    @api.createcollection(path)
    assert(@api.existscollection?(path))    
    path = "/db/testcollection/newcollection3/"
    @api.createcollection(path)
    assert(@api.existscollection?(path))
  end
  
  def test_02_getcollection
    col = @api.getcollection(@col_path)
    assert_not_nil(col)
  end
  
  def test_03_existscollection?()
    assert(@api.existscollection?(@col_path))
    col_path = "/db"
    assert(@api.existscollection?(col_path), '"'+col_path+"\" should exist and doesnt.")
    col_path = "db"
    assert(@api.existscollection?(col_path), '"'+col_path+"\" should exist and doesnt.")
    @api.createcollection("db/nexttest")
    col_path = "db/nexttest"
    assert(@api.existscollection?(col_path), '"'+col_path+"\" should exist and doesnt.")
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
    hits.times{ |hit|  
      city = @api.retrieve(handle, hit)
      retrieved_cities.push(city)
    }
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
    expr = "<capital>yes</capital>"
    pos = "into"
    expr_single = "#{@cities}//city[name=\"Praha\"]"
    @api.update_insert(expr, pos, expr_single)
    query = "#{@cities}//city[name=\"Praha\" and capital=\"yes\"]"
    handle = @api.execute_query(query)
    #puts query    
    hits = @api.get_hits(handle)
    #puts hits
    assert_equal(1, hits)
  end
  
  def test_10_update_replace
    test_09_update_insert
    expr = "#{@cities}//city[name=\"Praha\"]/capital"
    expr_single = "<capital_of>Czech Republic</capital_of>"
    @api.update_replace(expr, expr_single)
    handle = @api.execute_query("#{@cities}//city[capital_of=\"Czech Republic\"]")
    hits = @api.get_hits(handle)
    assert_equal(1, hits)
  end
  
  def test_11_update_value
    expr = "#{@cities}//city[name=\"Praha\"]/name/text()"
    expr_single = '"Prague"'
    @api.update_value(expr, expr_single)
    handle = @api.execute_query("#{@cities}//city[name=#{expr_single}]")
    hits = @api.get_hits(handle)
    assert_equal(1, hits)
  end
  
  def test_12_update_delete
    expr = "#{@cities}//city[name=\"Praha\"]"
    @api.update_delete(expr)
    handle = @api.execute_query("#{@cities}//city[name=\"Praha\"]")
    hits = @api.get_hits(handle)
    assert_equal(0, hits)
  end
  
  def test_13_update_rename
    expr = "#{@cities}//population"
    #puts expr
    expr_single = '"citizens"'
    @api.update_rename(expr, expr_single)
    handle = @api.execute_query("#{@cities}//population")
    hits = @api.get_hits(handle)
    assert_equal(0, hits)
    handle = @api.execute_query("#{@cities}//citizens")
    hits = @api.get_hits(handle)
    assert(hits>0)
  end
end
