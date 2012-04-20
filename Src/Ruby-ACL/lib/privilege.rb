class Privilege < ACL_Object
 
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}Privileges.xml\")"
  end
  
  def ge(temp_ace, final_ace, grid)
    temp = grid.find_index(temp_ace.priv)
    final = grid.find_index(final_ace.priv)
    return super(temp, final)
  end
end