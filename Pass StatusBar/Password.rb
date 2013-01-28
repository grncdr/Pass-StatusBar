#
#  Password.rb
#  Pass StatusBar
#
#  Created by Stephen Sugden on 2013-01-24.
#  Copyright 2013 Stephen Sugden. All rights reserved.
#
class Password
  
  # Find the path to gpg2 and cache it on the class object
  def self.gpg2_path
    return @gpg2_path if @gpg2_path
    usr_local = false
    ENV['PATH'].split(':').each do |dir|
      if dir == '/usr/local/bin'
        usr_local = true
      end
      if File.executable?(dir + '/gpg2')
        return dir + '/gpg2'
      end
    end
    # ensure we always check /usr/local
    unless usr_local
      if File.executable?('/usr/local/bin/gpg2')
        return '/usr/local/bin/gpg2'
      end
    end
  end

  def initialize(store_dir, filename)
    @store_dir = store_dir
    @filename = filename
  end
    
  def name
    @name ||= @filename.gsub(@store_dir + '/', '').gsub /\.gpg$/, ''
  end
    
  def toClipboard(sender=nil)
    pbcopy = IO.popen("pbcopy", 'w')
    pbcopy.write(decrypt)
    pbcopy.close
  end
  
  private
  def decrypt
    IO.popen("#{self.class.gpg2_path} -d --batch --quiet #{@filename}").readlines.last.strip
  end
end