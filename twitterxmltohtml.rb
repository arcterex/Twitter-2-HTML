#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'

# TODO 
#  - list tweets out that you want to process
#  - move into a class
#  - CLI interface
#  - config file?

# User configurable
user = "thinkinginrails"
# get the XML for the user
geturl = "http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{user}"

#doc = Nokogiri::XML(open(geturl))
doc = Nokogiri::XML(File.new('twitter.xml'))
# TODO - error checking

# grabbed from http://stackoverflow.com/questions/2034580/i-am-creating-a-twitter-clone-in-ruby-on-rails-how-do-i-code-it-so-that-the
def linkup_mentions_and_hashtags(text)    
	text.gsub!(/@([\w]+)(\W)?/, '<a href="http://twitter.com/\1">@\1</a>\2')
	text.gsub!(/#([\w]+)(\W)?/, '<a href="http://twitter.com/search?q=%23\1">#\1</a>\2')
	text
end

# deal with various tweet parsing code to link usernames, links, etc
def parsetweet(t)
	urls = URI.extract(t,%w[ http https ftp ])
	urls.each { |url| t.gsub!(url,"<a href=\"#{url}\">#{url}</a>") }
	
	# auto-link @usernames
	t = linkup_mentions_and_hashtags(t)
	t
end

doc.xpath('//status').each do |status| 
	tweetid = status.xpath('.//id').first.content
	datetext = status.xpath('.//created_at').first.content
	tweet = status.xpath('.//text').first.content

	url = "http://twitter.com/thinkinginrails/statuses/#{tweetid}"
	date = Date.parse(datetext)
	#datepretty = "#{date.year}/#{date.month}/#{date.day}"
	tweettext = parsetweet(tweet)
	puts "<li>#{tweettext} <em><a href=\"#{url}\">#</a></em></li>\n"
end

