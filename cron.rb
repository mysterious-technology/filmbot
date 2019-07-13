#! /usr/bin/env ruby

require 'rest_client'
require 'dotenv'
require 'json'

Dotenv.load

# == helpers ==

def execute(command)
    puts "> #{command}"
    result = system(command)
    if !result
        fail("⚠️ command failed")
    end
end

# from https://gist.github.com/harlantwood/2935203
# getting an oauth token: https://github.com/jwilger/github-v3-api
def push_to_github(params)
    repo = params[:repo]

    # get the head of the master branch
    # see http://developer.github.com/v3/git/refs/
    branch = github(:get, repo, "refs/heads/master")
    last_commit_sha = branch['object']['sha']

    # get the last commit
    # see http://developer.github.com/v3/git/commits/
    last_commit = github :get, repo, "commits/#{last_commit_sha}"
    last_tree_sha = last_commit['tree']['sha']

    # create tree object (also implicitly creates a blob based on content)
    # see http://developer.github.com/v3/git/trees/
    new_content_tree = github :post, repo, :trees,
                                :base_tree => last_tree_sha,
                                :tree => [{:path => params[:path], :content => params[:content], :mode => '100644'}]
    new_content_tree_sha = new_content_tree['sha']

    # create commit
    # see http://developer.github.com/v3/git/commits/
    new_commit = github :post, repo, :commits,
                        :parents => [last_commit_sha],
                        :tree => new_content_tree_sha,
                        :message => 'commit via api'
    new_commit_sha = new_commit['sha']

    # update branch to point to new commit
    # see http://developer.github.com/v3/git/refs/
    github :patch, repo, "refs/heads/master",
            :sha => new_commit_sha
end

def github(method, repo, resource, params={})
    resource_url = "https://#{ENV['GITHUB_USER']}:#{ENV['GITHUB_PASS']}@api.github.com" +
        "/repos/#{ENV['GITHUB_USER']}/#{repo}/git/#{resource}"
    if params.empty?
        JSON.parse RestClient.send(method, resource_url)
    else
        JSON.parse RestClient.send(method, resource_url, params.to_json, :content_type => :json, :accept => :json)
    end
end

# == cron ==

Process.fork do
  execute("./generate.rb -c nyc")
end
Process.fork do
  execute("./generate.rb -c sfbay")
end
Process.waitall
push_to_github :path => "nyc.html", :content => File.read('nyc.html'), :repo => 'filmbot'
push_to_github :path => "sfbay.html", :content => File.read('sfbay.html'), :repo => 'filmbot'


puts "pushed results"