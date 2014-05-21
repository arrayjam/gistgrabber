require "octokit"
require "git"

Octokit.auto_paginate = true

user = ARGV[0]

def usage
  puts "USAGE: ruby grab.rb username gists_path"
  exit
end

begin
  path = File.expand_path(ARGV[1])
rescue
  usage
end

usage unless user and path

puts "Querying GitHub Gists for #{user}'s gists… "

gists = Octokit.gists(user)

puts "Found #{gists.length} Gists."

gists.each do |gist|
  gist_dir = File.join(path, user, "raw")
  gist_path = File.join(gist_dir, gist.id)
  begin
    git = Git.open(gist_path)
    puts "Have #{gist.id}, fetching…"
    git.fetch
  rescue ArgumentError
    # Haven't cloned this gist yet
    FileUtils.mkdir_p gist_dir
    Git.clone(gist.git_pull_url, gist.id, path: gist_dir)
    puts "Cloning #{gist.id}"
  end
end

