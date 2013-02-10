#
#  AppDelegate.rb
#  Pass StatusBar
#
#  Created by Stephen Sugden on 2013-01-24.
#  Copyright 2013 Stephen Sugden. All rights reserved.
#
framework 'Cocoa'
require 'find'

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

  def generate_password(sender)
    genController = GeneratePasswordController.new
    genController.showWindow sender
  end

  private

  def defaults
    NSUserDefaults.standardUserDefaults
  end

  def each_password
    Find.find(store_dir).grep(/\.gpg$/).map do |filename|
      yield Password.new(filename)
    end
  end

  def show_menu(status_item_button)
    @menu.removeAllItems
    each_password do |pw|
      addMenuItem pw.name, action: 'toClipboard:', target: pw
    end

    @menu.addItem NSMenuItem.separatorItem
    addMenuItem store_dir.gsub(ENV['HOME'], '~'), enabled: false
    
    if not File.directory?(defaults["store_dir"])
      addMenuItem "Init password store", action: 'init_store_dir:'
    else
      addMenuItem "Change password store...", action: 'choose_store_dir:'
      addMenuItem "Generate password...", action: 'generate_password:', target: self
    end

    @menu.addItem NSMenuItem.separatorItem
    addMenuItem "Quit", action: 'terminate:', target: NSApplication.sharedApplication
    @status_item.popUpStatusItemMenu @menu
  end

  def addMenuItem(title, props)
    item = NSMenuItem.new
    item.title = title
    item.enabled = props.fetch(:enabled, true)
    if props.include?(:action)
      item.action = props[:action]
      item.target = props.fetch(:target, self)
    end
    @menu.addItem(item)
  end
end