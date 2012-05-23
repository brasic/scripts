#!/usr/bin/env ruby
# Migrate Vim undo files to a central directory.
# Carl Brasic
#
# Vim has an awesome feature letting you keep persistent undo files so that
# the 'u' command works across edit sessions. Enable this with
#
#     set undofile
#
# Usually Vim keeps the undo files in the same directory as the files being 
# edited.  They take the form of ~/.blah.rb.un~ for a file called blah.rb
#
# Keeping them littered all over the place is annoying -- it breaks tab
# completion among other things.  You can fix this with a .vimrc directive like
#
#     set udir=/home/user/.vim/undo
#
# and the files will be centralized like /home/user/.vim/undo/%home%user%blah.rb
# This script searches through PREFIX_DIR and moves all the .un~ files to the undo
# directory so you don't have to start over.
# Run this once with ACTUALLY_MOVE=false to ensure it's going to do the right thing
# then set ACTUALLY_MOVE to true and run again to move the files.  You might want
# to take a backup first.
require 'find'
require 'fileutils'

PREFIX_DIR    = "/home/#{ENV['USER']}/"
VIM_UNDO_DIR  = "/home/#{ENV['USER']}/.vim/undo/"
ACTUALLY_MOVE = false

# Ensure the dir exists.
FileUtils.mkdir_p VIM_UNDO_DIR

# get a list of the undo files. Might want to add other stuff here.
# This naively greps after getting the list, so if you have a lot of files 
# this will take a really long time...
origfiles = Find.find(PREFIX_DIR).to_a.
  grep(/\..*.un~/).                     # only return undo files
  reject{|x| x =~ /cache/}              # ignore cachey files

# make a hash of original file names => targets. Looks like
#  { 
#    '/home/user/.file1.un~' => '/home/user/.vim/undo/%home%user%file1',
#    '/home/user/.file2.un~' => '/home/user/.vim/undo/%home%user%file2'
#  }
newfiles = Hash[
    origfiles.map do |x|
      [ x, VIM_UNDO_DIR + x.gsub(/\/\.?/,'%').gsub('.un~','') ]
    end
  ]

# Actually move the files.  This is dangerous, make sure the list is correct.
cmds = newfiles.map do |src,dst|
  puts "mv #{src} #{dst}"
  FileUtils.mv(src,dst) if ACTUALLY_MOVE
end
