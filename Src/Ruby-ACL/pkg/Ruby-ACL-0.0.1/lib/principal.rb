class Principal < ACL_Object
  def initialize(connector, col_path)
    super(connector, col_path)
    @doc = "doc(\"#{@col_path}Principals.xml\")"
  end
  
  def exists?(name)
    query = "#{@doc}//#{self.class.name}s/descendant::*[@id=\"#{name}\"]"
    super(name, query)
  end
  
end
