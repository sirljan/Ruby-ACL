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

#Soupis jednotlivych vyjimek, v zavorce metoda tera tuto vyjimku vyhazuje
#1: Database login failed (DatabaseManager.connect)
#2: Failed to create Collection (DatabaseManager.createcollection)
#3: Failed to remove Collection (DatabaseManager.removecollection)
#
#10: Failed to initialize Collection (Collection.initialize)
#11: Failed to close Collection (Collection.close)
#12: No such child Collection (Collection.getchildcollection)
#13: Failed to get parent Collection (Collection.getparentcollection)
#14: Unknown resource (Collection.getresource)
#15: Failed to list child Collections (Collection.listchildcollection)
#16: Failed to list resources (Collection.listresources)
#17: Failed to remove resource (Collection.removeresource)
#18: Failed to store resource (Collection.storeresource)
#
#20: Failed to execute query (XPathQueryService.query)
#21: Failed to query Resource (XPathQueryService.queryresource)
#
#30: Failed to update Collection (XUpdateService.update)
#31: Failed to update Resource (XUpdateService.updateResource)
#