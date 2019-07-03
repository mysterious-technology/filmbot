#! /usr/bin/env ruby

result = system("./generate.rb -c nyc")
result == true ? (puts "✅") : (puts "❗")

result = system("./generate.rb -c sfbay")
result == true ? (puts "✅") : (puts "❗")

result = system("GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa_filmbot' git config user.name \"render\")
result == true ? (puts "✅") : (puts "❗")

result = system("GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa_filmbot' git config user.email \"benzguo@gmail.com\")
result == true ? (puts "✅") : (puts "❗")

result = system("GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa_filmbot' git remote add origin \"git@github.com:openscrape/filmbot.git\")
result == true ? (puts "✅") : (puts "❗")


result = system("GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa_filmbot' git commit -am \"render cron\"")
result == true ? (puts "✅") : (puts "❗")

result = system("GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa_filmbot' git push origin")
result == true ? (puts "✅") : (puts "❗")
