class Individual < ACL_Object
  
  
  
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}Principals.xml\")/Principals"
  end
  
  public
  def create_new(name, groups)
    super(name, groups)
  end
end

