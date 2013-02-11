#
#  Password.rb
#  Pass StatusBar
#
#  Created by Stephen Sugden on 2013-01-24.
#  Copyright 2013 Stephen Sugden. All rights reserved.
#
class Password
  
	attr_reader :name

  def initialize(name)
    @name = name
  end
    
  def toClipboard(sender=nil)
    pbcopy = IO.popen("pbcopy", 'w')
    pbcopy.write(PasswordStore.decrypt(name))
    pbcopy.close
  end
  
end
