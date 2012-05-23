#!/bin/env ruby
# Migrate undo files to a central directory
# Carl Brasic
require 'find'
require 'fileutils'

PREFIX_DIR    = '/home/brasca/'
VIM_UNDO_DIR  = '/home/brasca/.vim/undo/'
ACTUALLY_MOVE = false

# get a list of the undo files
origfiles = Find.find(PREFIX_DIR).to_a.
  grep(/\..*.un~/).                     # only return undo files
  reject{|x| x =~ /cache/}              # ignore cachey files

#make an array of file names and targets
# e.g. [ ['/home/brasca/.file1.un~', '/home/brasca/.vim/undo/%home%brasca%file1'],
#        ['/home/brasca/.file2.un~', '/home/brasca/.vim/undo/%home%brasca%file2'] ]
newfiles = origfiles.map do |x|
  [ x, VIM_UNDO_DIR + x.gsub(/\/\.?/,'%').gsub('.un~','') ]
end

cmds = newfiles.map do |src,dst|
  puts "mv #{src} #{dst}"
  FileUtils.mv(src,dst) if ACTUALLY_MOVE
end
