
module ActiveAXS
  module RecordSet
    def [] field
      self.Fields.Item(field).Value
    end

    def []= field,value
      self.Fields.Item(field).Value = value
    end

    def each_record
      if self.EOF or self.BOF
        return 
      end
      self.MoveFirst
      until self.EOF or self.BOF
        yield self
        self.MoveNext
      end
    end
  end
end
