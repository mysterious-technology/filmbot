#! /usr/bin/env ruby

result = system("./generate.rb -c nyc")
result == true ? (puts "✅") : (puts "❗")

result = system("./generate.rb -c sfbay")
result == true ? (puts "✅") : (puts "❗")

result = system("GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa_filmbot' git commit -am \"render cron\"")
result == true ? (puts "✅") : (puts "❗")

result = system("GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa_filmbot' git push")
result == true ? (puts "✅") : (puts "❗")