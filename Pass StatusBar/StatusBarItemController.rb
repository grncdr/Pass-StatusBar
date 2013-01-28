#
#  AppDelegate.rb
#  Pass StatusBar
#
#  Created by Stephen Sugden on 2013-01-24.
#  Copyright 2013 Stephen Sugden. All rights reserved.
#
framework 'Cocoa'

class StatusBarItemController
  attr_reader :store_dir
  
  def initialize
    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength)
    @menu = NSMenu.new
    @status_item.target = self
    @status_item.action = 'show_menu:'
    icon = NSImage.imageNamed 'icon'
    icon.size = NSSize.new(16, 16)
    @status_item.image = icon
    defaults.registerDefaults store_dir: ENV['HOME'] + '/.password-store'
  end
  
  def store_dir
    defaults["store_dir"]
  end
  
  def choose_store_dir(sender)
    dialog = NSOpenPanel.openPanel
    dialog.canChooseFiles = false
    dialog.canChooseDirectories = true
    dialog.allowsMultipleSelection = false
    # show the dialog
    if dialog.runModalForDirectory(nil, file: nil) == NSOKButton
      defaults["store_dir"] = dialog.filenames.first
      initMenu
    end
  end
    
  private
  
  def defaults
    NSUserDefaults.standardUserDefaults
  end
  
  def each_password
    Find.find(store_dir).grep(/\.gpg$/).map do |p|
      yield Password.new(store_dir, p)
    end
  end

  def show_menu(status_item_button)
    @menu.removeAllItems
    each_password do |pw|
      pwItem = NSMenuItem.new
      pwItem.title = pw.name
      pwItem.action = 'toClipboard'
      pwItem.target = pw
      @menu.addItem pwItem
    end
    
    @menu.addItem NSMenuItem.separatorItem
    @menu.addItem store_dir_item
    
    @menu.addItem browse_item
    @menu.addItem NSMenuItem.separatorItem
    @menu.addItem quit_item
    @status_item.popUpStatusItemMenu @menu
  end
  
  def store_dir_item
    item = NSMenuItem.new
    item.title = store_dir.gsub(ENV['HOME'], '~')
    item.enabled = false
    item
  end

  def browse_item
    item = NSMenuItem.new
    item.title = "Change password store..."
    item.action = 'choose_store_dir:'
    item.target = self
    item
  end
  
  def quit_item
    return @quit_item if @quit_item
    @quit_item = NSMenuItem.new
    @quit_item.title = 'Quit'
    @quit_item.action = 'terminate:'
    @quit_item.target = NSApplication.sharedApplication
    @quit_item
  end
end