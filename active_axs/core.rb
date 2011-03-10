
module ActiveAXS
  class Core
    
    # get table name
    def self.table_name
      self.to_s + "s"
    end

    # establish connection
    def self.establish_connection(config)
      define_attr_method :connect_source   , config[:source]   if config.has_key?(:source)
      define_attr_method :connect_user_id  , config[:user_id]  if config.has_key?(:user_id)
      define_attr_method :connect_password , config[:password] if config.has_key?(:password)
      create_connection.close
    end

    # private method
    private
    def self.define_attr_method(name, value)
      sing = class << self; self; end
      sing.class_eval "def #{name}; #{value.to_s.inspect}; end" 
    end

    # create connection
    def self.create_connection
      connection = WIN32OLE.new("ADODB.Connection").extend Connection
      connstr = ""
      if connect_source =~ /.*\mdb/
        connstr << "Driver={Microsoft Access Driver (*.mdb)};"
        connstr << "DBQ=#{connect_source};"
      else
        connstr << "DSN=#{connect_source};User ID=#{connect_user_id};Password=#{connect_password};"
      end
      connection.open(connstr)
      
      return connection
    end

    # execute select sql
    def self.execute_select(keys)
      execute_sql(ActiveAXS::SQLGenerator.create_select_sql(table_name , keys))
    end

    # execute delete sql
    def self.execute_delete(where)
      execute_sql(ActiveAXS::SQLGenerator.create_delete_sql(table_name , where))
    end

    # execute sql
    def self.execute_sql(sql)
      begin 
        connection = create_connection
        rs = connection.execute(sql)
        if sql =~ /insert/m || sql =~ /delete/m
          return 1
        end
        rs.extend ActiveAXS::RecordSet
        fields = rs.Fields
        list   = Array.new
        rs.each_record{|record|
          list.push(self.new(ActiveAXS::RecordMap.new(record , fields)))
        }
        list
      ensure
        connection.close if connection
      end
    end
  end

  # Connection
  module Connection
    def open(constr)
      self.Open constr
    end
    def close
      self.Close
    end
    def execute(sql)
      self.Execute(sql)
    end
  end
end
