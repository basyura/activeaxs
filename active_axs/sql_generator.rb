
module ActiveAXS
  class SQLGenerator
    def self.create_select_sql(table_name , keys={})
      orderby = keys.delete(:orderby)
      sql = "select * from #{table_name} "
      if !keys.empty?
        where = "where "
        keys.each{|key , value|
          key = key.to_s if key.kind_of? Symbol
          where << " and " if where != "where "
          if value.kind_of?(Integer) || value.kind_of?(Float)
            where << key + "=" + value.to_s + " "
          elsif value.match("%")
            where << key + " like '" + value + "' "
          else
            where << key + "='" + value + "' "
          end
        }
        sql << where
      end
      if orderby
        sql << "ORDER BY "
        if orderby.kind_of? String
          sql << orderby
        elsif orderby.kind_of Array
          for i in 0...orderby.length
            sql << "," if i != 0
            sql << keys[:orderby][i]
          end
        else
          raise Exception.new("not support :orderby's object")
        end
      end
      puts sql if $DEBUG
      sql
    end
  end
end
