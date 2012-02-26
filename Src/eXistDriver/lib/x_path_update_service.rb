# To change this template, choose Tools | Templates
# and open the template in the editor.

class XUpdateQueryService
  private
  @collection
  @parameters
  @path

  public
  def initialize(_col)
    @collection = _col.getserver
    @path = _col.getname
    @parameters = nil
  end

  def parameters
    @parameters
  end

  def parameters=(newparams)
    @parameters = newparams
  end

  def update(_commands)
    @collection.call("xupdate", _commands.to_s)
  rescue
    begin
      raise ExistException.new("Failed to update Collection", 30), "Failed to update Collection", caller
    end
  end


  # za boha to nemuzu rozjet, co jsem koukal, tak db vraci chybu No method matching arguments String String
  # ale i kdyz to prevedu na pole, tak to nejde
  def updateresource(_docname,_commands)
    res = @collection.call("xupdateResource", _docname.to_s, _commands.to_s)
    rescue
    begin
      raise ExistException.new("Failed to update resource", 31), "Failed to update resource", caller
    end
  end
end
