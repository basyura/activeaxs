
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
        elsif orderby.kind_of? Array
          for i in 0...orderby.length
            sql << "," if i != 0
            sql << orderby[i]
          end
        else
          raise Exception.new("not support :orderby's object")
        end
      end
      puts sql if $DEBUG
      sql
    end
    def self.create_delete_sql(table_name , where)
      sql = ""
      where.each_pair do |k , v|
        sql << " and " if sql != ""
        sql << "#{k}="
        sql << (v.kind_of?(String) ? "'#{v}'" : v.to_s)
      end
      "delete from #{table_name} where " + sql
    end
  end
end
