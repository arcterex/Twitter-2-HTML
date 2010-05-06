#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'date' 		# needed to make it run on my osx machine for some reason
require 'builder' 	# for constructing formats of output
require 'trollop' 	# parsing command line arguments

# TODO 
#  - list tweets out that you want to process
#  - move into a class
#  - CLI interface as per '10 things in ruby I wish I'd known'
#  - config file for user, etc
#  - use a filehandle for input/output
#  - rspec for testing
#  - pass in url for source


class Twitter2HTML
  # User configurable
  Default_twitter_username = "thinkinginrails"
  Default_input            = "http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{Default_twitter_username}"
  Default_url_prefix       = "http://twitter.com/thinkinginrails/statuses/"
  
  def initialize(username,input,output)
    @twitteruser = username || Default_twitter_username
    @input       = input    || Default_input
    @output      = output   || STDOUT
    
    #puts "Debug: username = #{@twitteruser} - input: #{@input} - output: #{@output}"
    @xml = load_xml(@input)
  end
  
  def output_html
    @xml.xpath('//status').each do |status| 
    	tweetid  = status.xpath('.//id').first.content
    	datetext = status.xpath('.//created_at').first.content
    	tweet    = status.xpath('.//text').first.content
    	date = Date.parse(datetext)
    	tweettext = parsetweet(tweet)
    	puts "<li>#{tweettext} <em><a href=\"#{Default_url_prefix}#{tweetid}\">#</a></em></li>\n"
    end
  end
  
private

  # grabbed from http://stackoverflow.com/questions/2034580/i-am-creating-a-twitter-clone-in-ruby-on-rails-how-do-i-code-it-so-that-the
  def linkup_mentions_and_hashtags(text)    
  	text.gsub!(/@([\w]+)(\W)?/, '<a href="http://twitter.com/\1">@\1</a>\2')
  	text.gsub!(/#([\w]+)(\W)?/, '<a href="http://twitter.com/search?q=%23\1">#\1</a>\2')
  	text
  end

  # deal with various tweet parsing code to link usernames, links, etc
  def parsetweet(t)
    URI.extract(t, %w[ http https ftp ]).each do |url|
      t.gsub!(url, "<a href=\"#{url}\">#{url}</a>")
    end
  	# auto-link @usernames
  	t = linkup_mentions_and_hashtags(t)
  end
  
  def load_xml(path)
    # catch if we can't parse the XML
    doc = Nokogiri::XML(open(path))
  end
end

# Defaults
input = "twitter.xml"
twitter_username = "thinkinginrails"

# Command line parsing
opts = Trollop::options do
	opt :config,   "Use a YAML config file"
	opt :username, "Use this twitter username",    :default => "thinkinginrails"
	opt :output,   "Output file (default STDOUT)", :default => STDOUT
end

p opts

#t = Twitter2HTML.new(twitter_username,input,STDOUT)
#t.output_html
