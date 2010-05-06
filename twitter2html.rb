#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'date'      # needed to make it run on my osx machine for some reason
require 'builder'   # for constructing formats of output
require 'trollop'   # parsing command line arguments

# TODO 
#  - list tweets out that you want to process
#  - move into a class
#  - CLI interface as per '10 things in ruby I wish I'd known'
#  - config file for user, etc
#  - use a filehandle for input/output
#  - rspec for testing
#  - pass in url for source


class TwitterXMLToHTML
  # User configurable
  Default_twitter_username = "thinkinginrails"
  Default_input            = "http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{Default_twitter_username}"
  Default_url_prefix       = "http://twitter.com/thinkinginrails/statuses/"
  
  def initialize(username,input,output)
    @twitteruser = username || Default_twitter_username
    @input       = input    || Default_input
    @output      = output   || STDOUT
    @tweets      = []
    
    #puts "Debug: username = #{@twitteruser} - input: #{@input} - output: #{@output}"
    @xml = load_xml(@input)
    @tweets = parse_tweets
  end
  
  def output_html_all
    @tweets.map { |t| output_html(t) }.join("\n")
  end
  
  def [](num)
    output_html(@tweets[num])
  end
  
private

  def output_html(t)
    "<li>#{t[:parsed_tweet]} <em><a href=\"#{Default_url_prefix}#{t[:ttweetid]}\">#</a></em></li>"
  end

  def get_tweet(num)
    output_html(@tweet[num])
  end
  
  # parse the XML and load up the @tweets array
  def parse_tweets
    @xml.xpath('//status').each do |status| 
    	id        = status.xpath('.//id').first.content
    	datetext  = status.xpath('.//created_at').first.content
    	tweet     = status.xpath('.//text').first.content
    	date      = Date.parse(datetext)
    	tweettext = parse_tweet(tweet)
      # puts "<li>#{tweettext} <em><a href=\"#{Default_url_prefix}#{tweetid}\">#</a></em></li>\n"
    	this_tweet = { :id => id, :tweet => tweet, :date => date, :parsed_tweet => tweettext }
    	@tweets << this_tweet
    end 
    @tweets   
  end
  
  # grabbed from http://stackoverflow.com/questions/2034580/i-am-creating-a-twitter-clone-in-ruby-on-rails-how-do-i-code-it-so-that-the
  def linkup_mentions_and_hashtags(text)    
  	text.gsub!(/@([\w]+)(\W)?/, '<a href="http://twitter.com/\1">@\1</a>\2')
  	text.gsub!(/#([\w]+)(\W)?/, '<a href="http://twitter.com/search?q=%23\1">#\1</a>\2')
  	text
  end

  # deal with various tweet parsing code to link usernames, links, etc
  def parse_tweet(t)
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

# Command line parsing
opts = Trollop::options do
       opt :config,   "Use a YAML config file"
       opt :username, "Use this twitter username",    :default => "thinkinginrails"
       opt :output,   "Output file (default STDOUT)", :default => STDOUT
end

p opts

input = "twitter.xml"
twitter_username = "thinkinginrails"

t = TwitterXMLToHTML.new(twitter_username,input,STDOUT)
puts t.output_html_all