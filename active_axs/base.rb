
module ActiveAXS

  # new ActiveAXS::Base with table name
  def self.Base(table_name)
    c = Class.new(ActiveAXS::Base)
    sig = class << c ; self end
    sig.send :define_method , :table_name , Proc.new{table_name}
    c
  end

  ##
  # ActiveAXS::Base
  class Base < ActiveAXS::Core
    include Enumerable

    # inherited
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
        list << [rec["Column_Name"].downcase.to_sym , rec["Data_Type"]]
      }
      subclass.send :define_method , :get_schema , Proc.new{list}
    end

    # initialize
    # new ActiveAXS::Base with record map
    # store record to instance variable
    def initialize(map)
      @__stored_map__ = {}
      map.each_pair do |key , value|
        @__stored_map__[key.downcase.to_sym] = value
      end
    end

    # save record. 
    # now this method is insert only
    def save
      # raise error if schema is not same between from and to.
      # so , create sql from record map
      #keys = get_schema.map{|v| v[0]}
      keys = @__stored_map__.keys
      sql = "insert into #{self.class.table_name} (#{keys.join(',')}) values( "

      keys.each_with_index do |key , index|
        v = @__stored_map__[key]
        sql << ',' if index != 0
        sql << (v.kind_of?(String) ? "'#{v}'" : v.to_s)
      end
      sql << ")"
      puts sql if $DEBUG
      self.class.execute_sql(sql)
    end

    # delete record with where keys
    # throw ArgumentError if where is empty
    def self.delete(where = {})
      raise ArgumentError if where.empty?
      execute_delete(where)
    end

    # find first record
    def self.find_first(keys)
      execute_select(keys).first
    end

    # find all record
    def self.find_all(keys={})
      execute_select(keys)
    end

    # find record with sql
    def self.find_by_sql(sql)
      raise Exception.new("not select sql") if sql.strip !~ /^select/i
      execute_sql(sql)
    end
    
    #
    def field_names
      get_schema.map{|v| v[0]}
    end

    #
    def each_field
      field_names.each do |v|
        yield v , @__stored_map__[v]
      end
    end

    def [](key)
      @__stored_map__[key.to_sym]
    end
    # accessor for record map
    def method_missing(method , *args)
      if method =~ /.*=/ && args.length == 1
        @__stored_map__[method.to_s.sub("=","").to_sym] = args[0]
      elsif method !~ /.*=/ && args.empty?
        @__stored_map__[method]
      else
        super
      end
    end
  end
end

