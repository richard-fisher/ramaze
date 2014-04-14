require 'yaml'
require 'yaml/store'
require 'ramaze'
require 'ramaze/spec/bacon'

spec_require 'bluecloth', 'nokogiri'

DB = YAML::Store.new('whywikitest.yaml')
END{ FileUtils.rm_f('whyikitest.yaml') }

require_relative '../start'

describe 'WikiController' do
  behaves_like :rack_test

  def page(name)
    page = get(name)
    page.status.should == 200
    page.body.should.not == nil

    doc = Nokogiri::HTML(page.body)
    title = doc.at('title').inner_text

    body = doc.at('body')
    return title, body
  end

  it 'should start' do
    get('/').status.should == 302
  end

  it 'should have main page' do
    title, body = page('/show/Home')
    title.should.match(/^MicroWiki Home$/)
    body.at('h1').inner_text.should == 'Home'
    body.css('a[@href="/edit/Home"]').inner_text.should == 'Create Home'
  end

  it 'should have edit page' do
    title, body = page('/edit/Home')
    title.should.match(/^MicroWiki Edit Home$/)

    body.css('a[@href="/"]').inner_text.should == '&lt; Home'
    body.at('h1').inner_text.should == 'Edit Home'
    body.at('form textarea').should.not == nil
  end

  it 'should create pages' do
    post('/save','text'=>'the text','page'=>'ThePage').status.should == 302
    page = Nokogiri::HTML(get('/show/ThePage').body)
    body = page.at('body>div')
    body.should.not == nil
    body.at('a[@href="/edit/ThePage"]').inner_text.should =='Edit ThePage'
    body.at('p').inner_text.should == 'the text'
  end
end
