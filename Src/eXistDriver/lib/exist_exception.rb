# To change this template, choose Tools | Templates
# and open the template in the editor.

class ExistException < RuntimeError

  @description
  @number

  def initialize(_description = "Epic fail \n", _number = nil)
    @description = _description + "\n"
    @number  = _number
  end

  def inspect
    self.tostring
  end

  def to_s
    self.tostring
  end

  def tostring
    @number.to_s + ": " +@description
  end

  def code
    @number
  end

end

#Soupis jednotlivych vyjimek, v zavorce metoda ktera tuto vyjimku vyhazuje
#1: Database login failed         (ExistAPI.connect)
#2: Failed to create Collection   (ExistAPI.createcollection)
#3: Failed to remove Collection   (ExistAPI.removecollection)
#4: Resource or document name is nil (ExistAPI.storeresource)
#5: Failed to store resource      (ExistAPI.storeresource)
#6: Failed to execute query       (ExistAPI.execute_query)
#7: Failed to retrieve resource   (ExistAPI.retrieve)
#8: Failed to get number of hits  (ExistAPI.get_hits)
#
#10: Failed to load Collection (Collection.load)
#11: Failed to load content of Document (Document.content)