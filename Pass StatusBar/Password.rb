#
#  Password.rb
#  Pass StatusBar
#
#  Created by Stephen Sugden on 2013-01-24.
#  Copyright 2013 Stephen Sugden. All rights reserved.
#

require 'securerandom'

class Password
  
  def self.generate(name, length, allowSymbols)
    message = if allowSymbols then :urlsafe_base64 else :hex end
    content = SecureRandom.send(message, length)
    command = gpg2_command(' -e -o "' + fileForName(name) + '"', 'w')
    command.write(content)
  end

  def self.gpg2_command(command, mode=nil)
    IO.popen("#{gpg2_path} #{command} -r #{gpg_id} --quiet --yes --batch ", mode)
  end

  def self.gpg_id
    File.open(store_dir + "/.gpg-id").readlines.first
  end

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

  def self.store_dir
    NSUserDefaults.standardUserDefaults["store_dir"]
  end

  def self.exists?(passwordName)
    File.exists?(fileForName(passwordName))
  end

  def self.fileForName(passwordName)
    store_dir + '/' + passwordName + '.gpg'
  end

  def initialize(filename)
    @filename = filename
  end
    
  def name
    @name ||= @filename.gsub(self.class.store_dir + '/', '').gsub /\.gpg$/, ''
  end
    
  def toClipboard(sender=nil)
    pbcopy = IO.popen("pbcopy", 'w')
    pbcopy.write(decrypt)
    pbcopy.close
  end
  
  private
  def decrypt
    self.class.gpg2_command('-d "' + @filename + '"').readlines.last.strip
  end
end