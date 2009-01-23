module ActiveAXS
  class Base < ActiveAXS::Core
    def initialize(map={})
      @map = map
    end
    def [](key) 
      @map[key]
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

