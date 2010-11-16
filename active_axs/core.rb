
module ActiveAXS
  class Core
    def self.table_name
      self.to_s + "s"
    end
    def self.set_source(source)
      define_attr_method :connect_source , source
    end
    def self.set_table_name(table_name)
      define_attr_method :table_name , table_name
    end
    def self.set_user_id(user_id)
      define_attr_method :connect_user_id , user_id
    end
    def self.set_password(password)
      define_attr_method :connect_password , password
    end
    def self.establish_connection(config)
      set_source(config[:source]) if config.has_key?(:source)
      set_user_id(config[:user_id]) if config.has_key?(:user_id)
      set_password(config[:password]) if config.has_key?(:password)
      create_connection.close
    end
    #
    # private method
    #
    private
    def self.define_attr_method(name, value)
      sing = class << self; self; end
      sing.class_eval "def #{name}; #{value.to_s.inspect}; end" 
    end
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

      
      # I want to get primary key. but I can't.
      #
      #set = connection.OpenSchema(20)
      #set.extend ActiveAXS::RecordSet
      #
      #set.each_record{|r|
      #  table_name = r["Table_Name"]
      #  schemas = connection.OpenSchema(4 , [nil, nil, table_name])
      #  schemas.extend ActiveAXS::RecordSet
      #  puts table_name
      #  schemas.each_record{|r2|
      #    puts r2["Column_Name"]
      #  }
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

      return connection
    end
    def self.execute_select(keys)
      sql = ActiveAXS::SQLGenerator.create_select_sql(table_name , keys)
      execute_sql(sql)
    end
    def self.execute_sql(sql)
      begin 
        connection = create_connection
        rs = connection.execute(sql)
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
