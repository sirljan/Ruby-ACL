$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/lib")
require 'Ruby-ACL'
#require 'dbi'

class Dbi_Connector
  @dbiacl = Ruby-ACL.new('dbiacl')
  
  def initialize
    
  end
  
  def Dbi_Connector.acl_query_pokus(string)
    puts string
  end

  def db_connect(db)
    DBI.connect(separate_db(desired_object), username, password)
  end

  def user_query(username, access_type, operation, desired_object ,query)
    if(@dbiacl.check(username, access_type, operation, desired_object)) 
      #query = "select * from people"
      stmt = db.prepare(query)
      stmt.execute
      while row = stmt.fetch do
        puts row.join(",")
      end
  
      stmt.finish
      db.disconnect
    else
      puts "Access denied to #{desired_object}."
    end
    return row
  end

  def acl_query(query)
    stmt = db.prepare(query)
    stmt.execute
    while row = stmt.fetch do
      puts row.join(",")
    end
    stmt.finish
    db.disconnect
    return rows
  end
end
