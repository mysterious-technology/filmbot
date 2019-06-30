#! /usr/bin/env ruby
# typed: false
require 'date'
require 'dotenv/load'
require 'mailchimp'
require 'slop'
require 'fileutils'

LIST_IDS = {
  'nyc' => {
    test: 'a03558b941',
    real: '7f90498afb'
  },
  'sf' => {
    test: '09e4b7c66b',
    real: 'e15df4841b'
  }
}

opts = Slop.parse { |o|
  o.string '-c', '--city', 'city to scrape'
  o.bool '--for-real', 'whether or not it\'s for real', default: false
}

Dotenv.load

city = opts[:city]
for_real = opts.for_real?

abort 'i need a city' unless city

puts for_real ? "~ for real this time ~" : "~ dry run ~"

ids_for_city = LIST_IDS[city]
abort 'no mailchimp ids for that city' unless ids_for_city
list_id = ids_for_city[for_real ? :real : :test]
abort 'no mail list' unless list_id


api_key = ENV['MAILCHIMP_API_KEY']
if api_key
  mailchimp = Mailchimp::API.new(api_key)
else
  abort 'No mailchimp api key; add it to a .env file'
end

today_string = Date.today.strftime('%b %e %Y')
timestamp = DateTime.now.strftime('%Y%m%dT%H%M')
subject = "~films this week~ #{today_string}"

if !for_real
  subject += ' [dry run]'
end

html = File.read('email.html')

if for_real
  FileUtils.cp_r('email.html', "archive/#{city}/#{timestamp}.html", remove_destination: true)
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

# TODO: open campaign URL

mailchimp.campaigns.send(campaign_id)

puts "~ sent ~"
