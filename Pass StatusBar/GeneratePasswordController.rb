#
#  GeneratePasswordController.rb
#  Pass StatusBar
#
#  Created by Stephen Sugden on 2013-01-29.
#  Copyright 2013 Stephen Sugden. All rights reserved.
#
class NSTextField
  def to_s
    stringValue
  end
end

class GeneratePasswordController < NSWindowController
  attr_accessor :allowSymbols
  attr_accessor :passwordName
  attr_accessor :passwordLength
  
  def init
    initWithWindowNibName "GeneratePassword"
  end
  
  def didClickCancel(sender)
    close
  end
  
  def didClickGenerate(sender)
    if PasswordStore.exists?(passwordName.stringValue)
			return unless shouldReplace?(passwordName.stringValue)
    end
		PasswordStore.generate(
			passwordName.stringValue,
			passwordLength.intValue,
			allowSymbols.state == NSOnState
		)
    close
  end

	def shouldReplace?(passwordName)
		alert = NSAlert.alertWithMessageText(
			"Password \"#{passwordName}\" already exists, would you like to replace it?",
			defaultButton: "Replace",
			alternateButton: "Cancel",
			otherButton: nil,
			informativeTextWithFormat: ""
		)
		alert.runModal == NSAlertDefaultReturn
	end
end
