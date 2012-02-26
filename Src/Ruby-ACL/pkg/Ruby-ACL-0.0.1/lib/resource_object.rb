class ResourceObject
  @@resOb_counter = 0
  def initialize(prescendet, descendents, name)
    @id = @@resOb_counter
#    @prescendet=prescendet
#    @descendents=descendents
    @name=name
    @address
  end
  attr_reader :name
  
  def to_s
    "#{name}"
  end
  
  public :to_s
  
end