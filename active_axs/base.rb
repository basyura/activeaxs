
module ActiveAXS
  class Base < ActiveAXS::Core
    include Enumerable
    def initialize(map={})
      fields = []
      sing = class << self; self end
      map.each_pair{|key,value|
        sing.send :define_method, key.downcase , Proc.new{value}
        fields << key.downcase
      }
#      @@fields = fields
      sing.send :define_method, :fields , Proc.new{fields}
    end
#    def self.fields
#      @@fields
#    end
    def each
      fields.each do |v|
        yield self.__send__(v)
      end
    end
    def save
      sql = "insert into #{self.class.table_name} values ("
      each_with_index do |v,index|
        sql << ',' if index != 0
        sql << (v.kind_of?(String) ? "'#{v}'" : v.to_s)
      end
      sql << ")"
      self.class.execute_sql(sql)
    end
    def self.find_first(keys)
      return execute_select(keys).first
    end
    def self.find_all(keys={})
      return execute_select(keys)
    end
    def self.find_by_sql(sql)
      raise Exception.new("not select sql") if sql.strip !~ /^select/i
      return execute_sql(sql)
    end
  end
end

