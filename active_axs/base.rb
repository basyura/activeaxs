
module ActiveAXS
  class Base < ActiveAXS::Core
    include Enumerable
    def initialize(map={})
      @__stored_map__ = {}
      map.each_pair do |key , value|
        @__stored_map__[key.downcase.to_sym] = value
      end
    end
    def save
      keys = @__stored_map__.keys

      sql = "insert into #{self.class.table_name} (#{keys.join(',')}) values( "

      keys.each_with_index do |key , index|
        v = @__stored_map__[key]
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
    def method_missing(method , *args)
      if method =~ /.*=/ && args.length == 1
        @__stored_map__[method.to_s.sub("=","")] = args[0]
      elsif method !~ /.*=/ && args.empty?
        @__stored_map__[method]
      else
        super
      end
    end
  end
end

