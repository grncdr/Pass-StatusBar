#
#  Password.rb
#  Pass StatusBar
#
#  Created by Stephen Sugden on 2013-01-24.
#  Copyright 2013 Stephen Sugden. All rights reserved.
#
require 'find'
require 'securerandom'

# The PasswordStore is a global constant that provides an interface to a
# directory containing encrypted passwords.
class PasswordStore
	class << self
    NSUserDefaults.standardUserDefaults.registerDefaults({
      store_dir: ENV['HOME'] + '/.password-store'
    })
  
    def defaults
      NSUserDefaults.standardUserDefaults
    end
		
		def store_dir
			defaults["store_dir"]
		end

		def store_dir=(new_dir)
			defaults["store_dir"] = new_dir
		end
  
    def initialized?
      File.exists?(store_dir)
    end

		def each
      if not initialized?
        return []
      end
			Find.find(store_dir).grep(/\.gpg$/).map do |filename|
				name = filename.gsub(store_dir + '/', '').gsub(/\.gpg$/, '')
				yield Password.new(name)
			end
		end

		def generate(name, length, allowSymbols)
			message = if allowSymbols then :urlsafe_base64 else :hex end
			content = SecureRandom.send(message, length)
			command = gpg2_command(' -e -o "' + fileForName(name) + '"', 'w')
			command.write(content)
		end

		def decrypt(name)
			gpg2_command('-d "' + fileForName(name) + '"').readlines.last.strip
		end

		def exists?(passwordName)
			File.exists?(fileForName(passwordName))
		end

    private

		def fileForName(passwordName)
			store_dir + '/' + passwordName + '.gpg'
		end

		def gpg2_command(command, mode=nil)
      command = "#{gpg2_path} -r #{gpg_id} --quiet --yes --batch #{command}"
      puts command
			IO.popen(command, mode)
		end

		def gpg_id
			@gpg_id ||= File.open(store_dir + "/.gpg-id").readlines.first.strip
		end

		# cached accessor for the gpg2 path
		def gpg2_path
			return @gpg2_path if @gpg2_path
			usr_local = false
			ENV['PATH'].split(':').each do |dir|
				if dir == '/usr/local/bin'
					usr_local = true
				end
				if File.executable?(dir + '/gpg2')
					@gpg2_path = dir + '/gpg2'
				end
			end
			# check /usr/local/bin even if it wasn't part of PATH
			unless usr_local
				if File.executable?('/usr/local/bin/gpg2')
					@gpg2_path = '/usr/local/bin/gpg2'
				end
			end
      @gpg2_path
		end

	end
end
