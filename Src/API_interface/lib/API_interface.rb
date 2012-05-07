require 'collection'

class API_interface
  
  #Create new instance of ExistAPI.
  #
  #example ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")    
  #
  # * *Args*    :
  #   - +uri+ -> uri of the db server
  #   - +username+ -> username
  #   - +password+  -> password to specified username
  # * *Returns* :
  #   -
  # * *Raises* :
  #   - +ExistException+ -> Database login failed
  #
  def initialize(uri = nil , username = nil, password = nil)
    raise "Must be implemented."
  end
  
  #Checks if collection with path exists or not.
  #
  # * *Args*    :
  #   - +path+ -> Path of the collection in db.
  # * *Returns* :
  #   -bolean. true -> exists, false -> doesn't exist
  # * *Raises* :
  #   - +nothing+
  #
  def existscollection?(collection_path)
    raise "Must be implemented."
    return bolean
  end
  
  #Creates collection with name in parrent(optionaly)
  #
  # * *Args*    :
  #   - +name+ -> the name of collection
  # * *Returns* :
  #   - the result of call
  # * *Raises* :
  #   - +ExistException+ -> if collection is not created.
  #
  def createcollection(collection_path)
    raise "Must be implemented."
  end
  
  #Removes collection with specified path.
  #
  # * *Args*    :
  #   - +path+ -> Path of the collection in db.
  # * *Returns* :
  #   - the result of call
  # * *Raises* :
  #   - +ExistException+ -> if failed to remove collection.
  #
  def remove_collection(_name)
    raise "Must be implemented."
  end

  #Returns Collection at specified path.
  #
  # * *Args*    :
  #   - +path+ -> Path of the collection in db.
  # * *Returns* :
  #   -instance of class Collection.
  # * *Raises* :
  #   - +nothing+
  #
  def getcollection(collection_path)
    raise "Must be implemented."
  end
  
  #Stores resource to document in db.
  #Inserts a new document into the database or replace an existing one:
  #
  # * *Args*    :
  #   - +_res+ -> resource which you want to safe. XML content of this document as a UTF-8 encoded byte array.
  #   - +_docname+ -> name of the document where to safe. Path to the database location where the new document is to be stored.
  #   - +_overwrite+ -> Set this value to > 0 to automatically replace an existing document at the same location.
  # * *Returns* :
  #   -bolean
  # * *Raises* :
  #   - +ExistException+ -> Resource or document name is nil
  #   - +ExistException+ -> Failed to store resource"
  def storeresource(xml_source_file, document_path_in_db)
    raise "Must be implemented."
  end
  
  #Executes an XQuery and returns a reference identifier to the generated result set. This reference can be used later to retrieve results.
  #
  # * *Args*    :
  #   - +xquery+ -> String xquery. A valid XQuery expression.
  #   - +parameters+ -> HashMap parameters. The parameters a HashMap values.
  #sort-expr :
  #namespaces :
  #variables :
  #base-uri :
  #static-documents :
  #protected : 
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +ExistException+ -> Failed to execute query
  #
  def execute_query(query)    #xpath, xQuery
    raise "Must be implemented."
    return handle
  end
  #Get the number of hits in the result-set identified by resultId.
  #example: gethits(handle_id)
  #
  # * *Args*    :
  #   - +handle+ -> Reference to a result-set as returned by a previous call to executeQuery.
  # * *Returns* :
  #   -the number of hits
  # * *Raises* :
  #   - +ExistException+ -> Failed to get number of hits
  #
  def get_hits(handle)
    raise "Must be implemented."
    return number_of_hits
  end
  #Retrieves a single result-fragment from the result-set referenced by resultId. 
  #The result-fragment is identified by its position in the result-set, which is passed in the parameter pos.
  #
  # * *Args*    :
  #   - +handle+ -> Reference to a result-set as returned by a previous call to executeQuery.
  #   - +pos+ -> The position of the item in the result-sequence, starting at 0.
  #   - +parameters+ -> A struct containing key=value pairs to configure the output.
  # * *Returns* :
  #   - the result of call
  # * *Raises* :
  #   - +ExistException+ -> Failed to retrive resource
  #
  def retrieve(handle, result_id)
    raise "Must be implemented."
    return result
  end
  
  #Inserts the content sequence specified in expr into the element node passed 
  #via exprSingle. exprSingle and expr should evaluate to a node set. 
  #If exprSingle contains more than one element node, the modification will be 
  #applied to each of the nodes. The position of the insertion is determined by 
  #the keywords "into", "following" or "preceding":
  #
  #
  # * *Args*    :
  #   - +expr+ -> The content is appended after the last child node of the specified elements.
  #   e.g.: <email type="office">andrew@gmail.com</email>, 
  #   - +pos+ -> The content is inserted immediately after the node specified in exprSingle.
  #   pos = "into" | "following" | "preceding"
  #   - +expr_single+ -> The content is inserted before the node specified in exprSingle.
  #   e.g. '//address[fname="Andrew"]'
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +nothing+
  def update_insert(expression, position, expression_location)
    raise "Must be implemented."
  end
  
  #Removes all nodes in expr from their document.
  #
  # * *Args*    :
  #   - +expr+ -> "//node()[@id="RockyRacoon"]
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +nothing+
  #
  def update_delete(expression)
    raise "Must be implemented."
  end
  
  #Updates the content of all nodes in expr with the items in exprSingle. 
  #If expr is an attribute or text node, its value will be set to the 
  #concatenated string value of all items in exprSingle.
  #
  # * *Args*    :
  #   - +expr+ -> "//node()[@id="RockyRacoon"]/@id"
  #   - +expr_single+ -> '"RockyR"'
  # * *Returns* :
  #   -int handle of query
  # * *Raises* :
  #   - +nothing+
  #
  def update_value(expr_value_identification, expr_new_value)
    raise "Must be implemented."
  end
  
end
