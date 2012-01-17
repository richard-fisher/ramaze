##
# The User model is user for retrieving and authenticating users. This
# application uses bcrypt to hash the passwords. For more information on bcrypt
# see the following pages:
#
# * http://codahale.com/how-to-safely-store-a-password/
# * http://yorickpeterse.com/articles/use-bcrypt-fool/
# * https://github.com/codahale/bcrypt-ruby
#
# @since  26-09-2011
#
class User < Sequel::Model
  # A user can have any number of posts and comments.
  one_to_many :posts
  one_to_many :comments

  ##
  # User.authenticate() is used to authenticate a user. Each request the User
  # helper calls this method to see if the currently logged in user is a valid
  # user. Once called this methods queries the database and returns a valid User
  # object in case the specified details were correct or something that
  # evaluates to false if this wasn't the case.
  #
  # @since  26-09-2011
  # @param  [Hash] creds A hash containing the username and password of the
  #  currently logged in user.
  # @return [Users|FalseClass]
  #
  def self.authenticate(creds)
    username, password = creds['username'], creds['password']

    if creds['username'].nil? or creds['username'].empty?
      return false
    end

    # Let's see if there is a user for the given username.
    user = self[:username => username]

    # Validate the user. Note that while it may seem that the password is
    # compared as plain text this is not the case. The bcrypt class
    # automatically converts the given password to a bcrypt hash. If these
    # hashes are the same the specified password is correct.
    if !user.nil? and user.password == password
      return user
    else
      return false
    end
  end

  ##
  # In order to properly use bcrypt we have to override the password=() and
  # password() methods to return a correct bcrypt hash/object rather than
  # whatever was stored in the database as a String instance.
  #
  # @since  26-09-2011
  # @param  [String] password The new password of a user.
  #
  def password=(password)
    # Passing an empty password to the BCrypt class triggers errors.
    if password.nil? or password.empty?
      return
    end

    # Generates a new bcrypt password using a cost of 10. In my opinion a cost
    # higher than 10 makes a web based application too slow.
    password = BCrypt::Password.create(password, :cost => 10)

    super(password)
  end

  ##
  # Because the password=() is overwritten with a custom one we also have to
  # define a matching getter. Without this you'd get an instance of String
  # containing the bcrypt hash and thus wouldn't be able to properly compare it
  # to other passwords.
  #
  # @since  26-09-2011
  # @return [BCrypt::Password|NilClass]
  #
  def password
    password = super

    if !password.nil?
      return BCrypt::Password.new(password)
    else
      return nil
    end
  end

  ##
  # Validates an instance of this model. See Post#validate() for some extra
  # details on how this works.
  #
  # @since  26-09-2011
  #
  def validate
    validates_presence(:username)
    validates_presence(:password) if new?
  end
end # User
