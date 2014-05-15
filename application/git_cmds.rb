#require 'java'
require 'rubygems'
require 'git'
class GitCmds

  def initialize
    g = Git.open (File.dirname(__FILE__)) #, :log => Logger.new(STDOUT))
    g.add('.')
    g.commit(ARGV[0].to_s)
  end
  
end