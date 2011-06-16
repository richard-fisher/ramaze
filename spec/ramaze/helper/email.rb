require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/helper/email'

include Ramaze::Helper::Email

# Modify Net::SMTP so it doesn't actually send the Emails
class Net::SMTP
  MockData = {
    :email     => nil,
    :sender    => nil,
    :receivers => [],
    :helo      => nil,
    :user      => nil,
    :secret    => nil,
    :auth_type => nil
  }

  def start(helo = 'localhost', user = nil, secret = nil, auth_type = nil)
    MockData[:helo], MockData[:user], MockData[:secret], MockData[:auth_type] = helo, \
      user, secret, auth_type

    if block_given?
      return yield(self)
    else
      return self
    end
  end

  # Rather than sending the Email we'll store them in a variable
  def send_message(email, sender, *to_addrs)
    MockData[:email], MockData[:sender], MockData[:receivers] = email, sender, to_addrs
  end
end # Net::SMTP

describe Ramaze::Helper::Email do

  it('The options should be available') do
    Ramaze::Helper::Email.options.host.should.equal ''
    Ramaze::Helper::Email.options.auth_type.should.equal :login
  end

  it('The options should be editable') do
    Ramaze::Helper::Email.options.host = 'smtp.awesome.tld'
    Ramaze::Helper::Email.options.host.should.equal 'smtp.awesome.tld'
  end

  it('Send an Email') do
    Ramaze::Helper::Email.options.host     = 'smtp_host'
    Ramaze::Helper::Email.options.username = 'smtp_user'
    Ramaze::Helper::Email.options.password = 'smtp_pass'
    Ramaze::Helper::Email.options.sender   = 'email@domain.tld'

    send_email('email@domain.tld', 'simple', 'This is a simple email')

    Net::SMTP::MockData[:helo].should.empty
    Net::SMTP::MockData[:sender].should.equal    'email@domain.tld'
    Net::SMTP::MockData[:user].should.equal      'smtp_user'
    Net::SMTP::MockData[:secret].should.equal    'smtp_pass'
    Net::SMTP::MockData[:auth_type].should.equal :login

    # Right, time to validate the actual Email itself
    [
      /From: email@domain\.tld/,  /To: <email@domain\.tld>/, /Subject: simple/, /\r\n/
    ].each do |regex|
      Net::SMTP::MockData[:email].should.match regex
    end
  end

end
