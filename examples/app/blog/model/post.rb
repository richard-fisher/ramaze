##
# The Post class is a model that's used for managing posts. The corresponding
# table is called "posts". For more information on how Sequel works see the
# following page: http://sequel.rubyforge.org/documentation.html
#
# @since  26-09-2011
#
class Post < Sequel::Model
  # The timestamps plugin is used to automatically fill two database columns
  # with the dates and times on which an object was created and when it was
  # modified.
  plugin :timestamps, :create => :created_at, :update => :updated_at

  # Multiple posts can only belong to a single user.
  many_to_one :user
  one_to_many :comments

  ##
  # Post#validate() is called whenever an instance of this class is saved or
  # updated. For more information on what you can do with this method see the
  # following page:
  # http://sequel.rubyforge.org/rdoc/files/doc/validations_rdoc.html
  #
  # If you're used to working with ActiveRecord it's important to remember that
  # these validation methods can't be used in a model's class declaration, they
  # have to be placed inside the #validate() method.
  #
  # @since  26-09-2011
  #
  def validate
    validates_presence([:title, :body])
  end
end # Post
