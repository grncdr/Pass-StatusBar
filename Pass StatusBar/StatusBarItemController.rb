#
#  AppDelegate.rb
#  Pass StatusBar
#
#  Created by Stephen Sugden on 2013-01-24.
#  Copyright 2013 Stephen Sugden. All rights reserved.
#
class StatusBarItemController

  def initialize
    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength)
    @menu = NSMenu.new
    @status_item.target = self
    @status_item.action = 'show_menu:'
    icon = NSImage.imageNamed 'icon'
    icon.size = NSSize.new(16, 16)
    @status_item.image = icon
  end

  def choose_store_dir(sender)
    dialog = NSOpenPanel.openPanel
    dialog.canChooseFiles = false
    dialog.canChooseDirectories = true
    dialog.allowsMultipleSelection = false
    # show the dialog
    if dialog.runModalForDirectory(nil, file: nil) == NSOKButton
			PasswordStore.store_dir = dialog.filenames.first
    end
  end
  
  def open_store_dir(sender)
    NSWorkspace.sharedWorkspace.openFile PasswordStore.store_dir
  end

  def generate_password(sender)
    genController = GeneratePasswordController.new
    genController.showWindow sender
  end

  private

  def show_menu(status_item_button)
    @menu.removeAllItems
    
    if PasswordStore.initialized?
      PasswordStore.each do |pw|
        addMenuItem pw.name, action: 'toClipboard:', target: pw
      end

      @menu.addItem NSMenuItem.separatorItem
      addMenuItem "Open #{PasswordStore.store_dir.gsub(ENV['HOME'], '~')}", action: 'open_store_dir:'
      addMenuItem "Generate password...", action: 'generate_password:'
    else
      addMenuItem "Init password store", action: 'init_store_dir:'
    end

    addMenuItem "Choose password store...", action: 'choose_store_dir:'

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
