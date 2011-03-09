
module ActiveAXS
  def self.Base(table_name)
    c = Class.new(ActiveAXS::Base)
    sig = class << c ; self end
    sig.send :define_method , :table_name , Proc.new{table_name}
    c
  end
  class Base < ActiveAXS::Core
    include Enumerable

    def self.inherited(subclass)
      super

      return if subclass.superclass == ActiveAXS::Base

      table = subclass.table_name
      if table.index("\.")
        table = table_name.split("\.")[1]
      end

      list = []
      schema = create_connection.OpenSchema(4 , [nil, nil, table])
      schema.extend ActiveAXS::RecordSet
      schema.each_record{|rec|
        list << [rec["Column_Name"] , rec["Data_Type"]]
      }
      #sig = class << subclass ; self end
      #sig.send :define_method , :get_schema , Proc.new{list}
      subclass.send :define_method , :get_schema , Proc.new{list}

      #set.each_record{|r|
        #table_name = r["Table_Name"]
        #schemas = connection.OpenSchema(4 , [nil, nil, table_name])
        #schemas.extend ActiveAXS::RecordSet
        #puts table_name
        #schemas.each_record{|r2|
          #puts r2["Column_Name"]
        #}
      #}
      # get fields
      #schemas = connection.OpenSchema(4 , [nil, nil, table_name])
      #schemas.extend ActiveAXS::RecordSet
      #schemas.each_record{|r2|
      #  puts r2["Column_Name"] + "-" + r2["Data_Type"].to_s
      #}
      #primary = connection.OpenSchema(28 , ["pubs", "dbo", table_name])
      #primary.extend ActiveAXS::RecordSet
      #primary.each_record{|r2|
      #  puts r2["Column_Name"]
      #}
    end
    def initialize(map)
      @__stored_map__ = {}
      map.each_pair do |key , value|
        @__stored_map__[key.downcase.to_sym] = value
      end
    end
    def ondb?
      @ondb
    end
    def save

      #raise StandardError.new('not suppoted') if @__stored_map__.empty?

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
    def self.delete(where = {})
      raise ArgumentError if where.empty?
      execute_delete(where)
    end
    def self.find_first(keys)
      execute_select(keys).first
    end
    def self.find_all(keys={})
      execute_select(keys)
    end
    def self.find_by_sql(sql)
      raise Exception.new("not select sql") if sql.strip !~ /^select/i
      execute_sql(sql)
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

