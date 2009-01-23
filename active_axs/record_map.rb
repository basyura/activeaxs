
module ActiveAXS
  class RecordMap
    def initialize(record , fields)
      @map = Hash.new
      for field in fields
        @map[field.Name] = record[field.Name]
      end
    end
    def [](key) 
      key = key.to_s if key.kind_of? Symbol
      @map[key]
    end
    def to_s
      @map.to_s
    end
  end
end
