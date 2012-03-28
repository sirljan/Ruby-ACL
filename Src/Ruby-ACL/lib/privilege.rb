class Privilege < ACL_Object
  
 
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}Privileges.xml\")"
  end
  
end