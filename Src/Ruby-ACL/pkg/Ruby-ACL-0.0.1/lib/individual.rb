class Individual < Principal
  
  def initialize(connector, col_path)
    super(connector, col_path)
  end
  
  public
  def create_new(name, groups)
    super(name, groups)
  end
end

