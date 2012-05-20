Gem::Specification.new do |s|
  s.name        = 'Ruby-ACL'
  s.version     = '1.0.5'
  s.date        = '2012-05-20'
  s.summary     = "Easy Access Control List based on 3 dimensional concept. It needs XML database and implemantion of API. e.g. eXist-db and eXistAPI."
  s.description = "Ruby-ACL is library that handles access permisions. Ruby-ACL offers to create and modify three ACL objects - three dimensions: Principal, Privilege, Resource object."
  s.authors     = ["Jenda Sirl"]
  s.email       = 'jan.sirl@seznam.cz'
  s.files       = 
    ["lib/ACL_Object.rb","lib/Ruby-ACL.rb","lib/ace.rb","lib/ace_rule.rb", 
    "lib/group.rb", "lib/individual.rb", "lib/principal.rb", "lib/privilege.rb", 
    "lib/resource_object.rb", "lib/rubyacl_exception.rb", 
    "lib/src_files/Principals.xml", "lib/src_files/Privileges.xml", 
    "lib/src_files/ResourceObjects.xml", "lib/src_files/acl.xml"]
  s.homepage    = 'http://rubygems.org/gems/ruby-acl'
end