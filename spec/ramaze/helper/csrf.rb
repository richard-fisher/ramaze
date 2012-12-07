require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/helper/csrf'

class SpecHelperCSRF < Ramaze::Controller

  engine :none
  helper :csrf

  before_all do
    csrf_protection :check_post, :protect_me do
      respond("The specified CSRF token is incorrect.", 401)
    end
  end

  def index
    generate_csrf_token
  end

  def get
    return get_csrf_token
  end

  def check_post
    "POST allowed."
  end

  def get_token
    get_csrf_token
  end
end

describe Ramaze::Helper::CSRF do
  behaves_like :rack_test

  it 'generate a new csrf token' do
    got = get '/'

    got.status.should.equal 200
    got.body.should.equal ''
  end

  it 'retrieve the current CSRF token' do
    got = get '/get'

    got.status.should.equal 200
    got.body.length.should.equal 128
  end

  it 'validate all HTTP requests' do
    methods = [:get, :post, :put, :delete]

    methods.each do |method|
      token       = get('/get_token').body
      got_invalid = self.send(method, '/check_post', :name => "Yorick Peterse")
      got_valid   = self.send(method, '/check_post', :csrf_token => token)

      got_invalid.status.should.equal 401
      got_invalid.body.should.equal "The specified CSRF token is incorrect."

      got_valid.status.should.equal 200
      got_valid.body.should.equal "POST allowed."
    end
  end
end
