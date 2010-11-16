
module ActiveAXS
  class RecordMap
    def initialize(record , fields)
      @map = Hash.new
      for field in fields
        value = record[field.Name]
        case field.Type
          # êîíl
          when 131
            value = value.to_i
        end
        @map[field.Name] = value
      end
    end
    def [](key) 
      key = key.to_s if key.kind_of? Symbol
      @map[key]
    end
    def each_pair
      @map.each_pair{|key,value| yield(key,value) }
    end
    def to_s
      @map.to_s
    end
  end
end
