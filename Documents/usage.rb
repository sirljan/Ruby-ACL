require 'Ruby-ACL'
require 'dbi'

acl = Racl.new("test1")

username = "pepanovak"
password = "tajneheslo"
desired_operation = "select"
desired_object = "dbi:OCIU:mydb/people"

if(Racl.acl_check(username,desired_operation,desired_object)) then
  db = DBI.connect(separate_db(desired_object), username, password)
  query = "select * from people"
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


require 'Ruby-ACL'

username = "pepanovak"
access_type = "deny"
desired_privilege = "create"
desired_object = "dbi:OCIU:mydb"

acl = Racl.new("test2")
acl.init_from_db("dbi:OCIU:mydb")                               #nacte a spracuje 
acl.set(username,access_type,desired_privilege,desired_object)	#vsechny ResourceObejcts 
                                                                #vsechny Principals



  