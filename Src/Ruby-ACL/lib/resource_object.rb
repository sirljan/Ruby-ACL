class ResourceObject
  def initialize(prescendet, descendents, name)
    @prescendet=prescendet
    @descendents=descendents
    @name=name
    #@address
  end
  attr_reader :name
  
  def to_s
    "#{name}"
  end
end