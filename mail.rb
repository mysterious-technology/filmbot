#! /usr/bin/env ruby
require 'date'
require 'dotenv/load'
require 'mailchimp'

Dotenv.load

mailchimp = Mailchimp::API.new(ENV['MAILCHIMP_API_KEY'])

today_string = Date.today.strftime('%b %e %Y')
timestamp = DateTime.now.strftime('%Y%m%dT%H%M')
subject = "~films this week~ #{today_string}"
html = File.read('email.html')

list_id = "a03558b941" # dry run by default
if ARGV[0] == "PLEASE"
  puts "~ for real this time ~"
  list_id = "7f90498afb"
else
  puts "~ dry run ~"
end
from_email = "filmbotnyc@gmail.com"
from_name = "filmbot"
to_name = "*|FNAME|*"

opts = {
  list_id: list_id,
  subject: subject,
  from_email: from_email,
  from_name: from_name,
  to_name: to_name,
  auto_footer: false,
  generate_text: true,
}
content = {
  html: html
}

response = mailchimp.campaigns.create("regular", opts, content)
campaign_id = response["id"]
mailchimp.campaigns.send(campaign_id)

puts "~ sent ~"
