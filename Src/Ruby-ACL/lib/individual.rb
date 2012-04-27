class Individual < Principal
  
  def initialize(connector, col_path, report = false)
    super(connector, col_path, report)
  end
  
  public
  def create_new(name, groups)
    super(name, groups)
  rescue => e
    raise e
  end
end

