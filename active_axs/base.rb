module ActiveAXS
  class Base < ActiveAXS::Core
    def initialize(map={})
      sing = class << self; self end
      map.each_pair{|key,value|
        #sing.class_eval "def #{key.downcase}; #{value.to_s.inspect}; end" 
        sing.send :define_method, key.downcase , Proc.new{value}
      }
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

