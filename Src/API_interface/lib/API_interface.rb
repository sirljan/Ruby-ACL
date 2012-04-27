require 'collection'

class API_interface
  def initialize(uri = nil , username = nil, password = nil)
    raise "Must be implemented."
  end
  
  def existscollection?(collection_path)
    raise "Must be implemented."
    return bolean
  end
  
  def createcollection(collection_path)
    raise "Must be implemented."
  end
  
  def remove_collection(_name)
      raise "Must be implemented."
  end

  
  def getcollection(collection_path)
    raise "Must be implemented."
  end
  
  #store resource from local storage into db
  def storeresource(xml_source_file, document_path_in_db)
    raise "Must be implemented."
  end
  
  def execute_query(query)    #xpath, xQuery
    raise "Must be implemented."
    return handle
  end
  
  def get_hits(handle)
    raise "Must be implemented."
    return number_of_hits
  end
  
  def retrieve(handle, result_id)
    raise "Must be implemented."
    return result
  end
  
  def update_insert(expression, position, expression_location)
    raise "Must be implemented."
  end
  
  def update_delete(expression)
    raise "Must be implemented."
  end
  
  def update_value(expr_value_identification, expr_new_value)
    raise "Must be implemented."
  end
  
end
