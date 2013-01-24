//
//  main.m
//  Pass StatusBar
//
//  Created by Stephen Sugden on 2013-01-24.
//  Copyright (c) 2013 Stephen Sugden. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
