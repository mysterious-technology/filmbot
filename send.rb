#! /usr/bin/env ruby

require 'date'
require 'dotenv'
require 'mailgun-ruby'
require 'mail'

Dotenv.load

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'gmail.com',
            :user_name            => 'filmbotnyc@gmail.com',
            :password             => ENV['GOOGLE_PW'],
            :authentication       => 'plain',
            :enable_starttls_auto => true,
          }
Mail.defaults do
  delivery_method :smtp, options
end

today_string = Date.today.strftime('%b %e %Y')
subject = "~films this week~ #{today_string}"

emails = [
  'benzguo@gmail.com'
]
emails.each do |email|
  mail = Mail.deliver do
    to      email
    from    'film bot <filmbotnyc@gmail.com>'
    subject subject

    html_part do
      content_type 'text/html; charset=UTF-8'
      body File.read('email.html')
    end
  end
end

# TODO: use mailgun
# mg_client = Mailgun::Client.new(ENV['MAILGUN_API_KEY'])
# message_params =  { from: 'benzguo@gmail.com',
#                     to:   'benguo@gmail.com',
#                     subject: 'filmbot',
#                     body_html: result,
#                   }
# mg_client.send_message('http://othernet.com', message_params
