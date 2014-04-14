# written as an example of how to implement the minimal _why wiki

require 'rubygems'
require 'ramaze'
require 'yaml/store'
require 'bluecloth'

DB = YAML::Store.new('whywiki.yaml') unless defined?(DB)

class WikiController < Ramaze::Controller
  map :/

  def index
    redirect r(:show, 'Home')
  end

  def show page = 'Home'
    @page = url_decode(page)
    @text = DB.transaction{|db| db[page] }.to_s
    @edit_link = "/edit/#{page}"

    @text.gsub!(/\[\[(.*?)\]\]/) do |m|
      exists = DB.transaction{|db| db[$1] } ? 'exists' : 'nonexists'
      A($1, :href => rs(:show, url_encode($1)), :class => exists)
    end

    @text = BlueCloth.new(@text).to_html
  end

  def edit page = 'Home'
    @page = url_decode(page)
    @text = DB.transaction{|db| db[page] }
  end

  def save
    redirect_referer unless request.post?

    page = request['page'].to_s
    text = request['text'].to_s

    DB.transaction{|db| db[page] = text }

    redirect rs(:show, url_encode(page))
  end
end

Ramaze.start host: '0.0.0.0'
