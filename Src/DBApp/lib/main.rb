$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/Ruby-ACL/lib")
require 'Ruby-ACL'
require 'mysql'

class Mysql_Connector
  @mysqlacl = Ruby-ACL.new('mysqlacl')
  
  def initialize
    
  end
  
  def Mysql_Connector.acl_query_pokus(string)
    puts string
  end

  def db_connect(server, username, password, db)
    @m = Mysql.new(server, username, password, db)
  end
  
  #"SELECT * FROM people ORDER BY name"
  
  def user_query(username, access_type, operation, desired_object ,query)
    if(@dbiacl.check(username, access_type, operation, desired_object))
      r = @m.query(query)
      #      r.each_hash do |f|
      #        print "#{f['name']} - #{f['email']}"
      #      end
    end
    return r
  end
  
  def acl_query(query)
    @m.query(query)
  end
  
end



#dbacl = Ruby_acl.new("dbacl")
#dbacl.principals

#username = "pepanovak"
#password = "tajneheslo"
#desired_operation = "select"
#desired_object = "dbi:OCI8:mydb/people"


