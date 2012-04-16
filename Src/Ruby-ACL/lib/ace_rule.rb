class AceRule
  
  attr_reader :prin
  attr_reader :priv
  attr_reader :res_obj
  attr_reader :acc_type
  
  def initialize(ace_id)
    query = "#{@ace.doc}//Ace[@id=\"#{ace_id}\"]/Principal/string(@idref)"
    handle = @connector.execute_query(query)
    @prin = @connector.retrieve(handle, 0)
    
    query = "#{@ace.doc}//Ace[@id=\"#{ace_id}\"]/Privilege/string(@idref)"
    handle = @connector.execute_query(query)
    @priv = @connector.retrieve(handle, 0)
    
    query = "#{@ace.doc}//Ace[@id=\"#{ace_id}\"]/ResourceObject/string(@idref)"
    handle = @connector.execute_query(query)
    @res_obj = @connector.retrieve(handle, 0)
    
    query = "#{@ace.doc}//Ace[@id=\"#{ace_id}\"]/accessType/text()"
    handle = @connector.execute_query(query)
    @acc_type = @connector.retrieve(handle, 0)
  end
end
