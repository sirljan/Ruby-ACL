#TODO test coverige
#TODO testy v rake http://guides.rubygems.org/make-your-own-gem/#writing-tests

#$:.unshift("./test")

require 'test/unit' 
require 'simplecov'
SimpleCov.start

# Add your testcases here

require_relative 'tc_rubyacl_set1' #methods close to ACL 
require_relative 'tc_rubyacl_set2' #Create methods of ACL Objects
require_relative 'tc_rubyacl_set3' #Modify methods of ACL Obejcts
require_relative 'tc_rubyacl_set4' #Only RubyACL.check method
