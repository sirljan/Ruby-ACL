class Privilege
  @@default_privileges = ['ALL PRIVILEGES', 'ALTER', 'CREATE', 'DELETE', 'DROP', 
    'FILE', 'INDEX', 'INSERT', 'PROCESS', 'REFERENCES', 'RELOAD', 'SELECT', 
    'SHUTDOWN', 'UPDATE', 'USAGE']
  def initialize(access_type, operation)    #
    if(access_type == "allow" || access_type == "deny")
      @access_type = access_type    #access type by mel byt enumeration: allow,deny
    else
      puts "Access type \"#{access_type}\" is not valid"
    end
    @operation = operation
  end
  
  attr_reader :access_type, :operation
  
  public
  
  def Privilege.default_privileges
    @@default_privileges
  end
  
  def to_s
    return "#{access_type} \t #{operation}"    
  end
  
end