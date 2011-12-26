class ResourceObject
  def initialize(prescendet, descendents, name)
    @prescendet=prescendet
    @descendents=descendents
    @name=name
  end
  attr_reader :name
end