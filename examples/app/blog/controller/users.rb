##
# The Users controller is used for managing users and allowing existing users to
# log in.
#
# @author Yorick Peterse
# @since  26-09-2011
#
class Users < BaseController
  map '/users'

  # The user has to be logged in in order to access this controller. The only
  # exception is the login() method.
  before_all do
    if action.method.to_sym != :login and !logged_in?
      flash[:error] = 'You need to be logged in to view that page'
      redirect(Users.r(:login))
    end
  end

  ##
  # Shows an overview of all the users that have been added to the database.
  #
  # @author Yorick Peterse
  # @since  27-09-2011
  #
  def index
    @users = paginate(User)
    @title = 'Users'
  end

  ##
  # Allows users to add another user to the database.
  #
  # @author Yorick Peterse
  # @since  27-09-2011
  #
  def new
    @user  = flash[:form_data] || User.new
    @title = 'New user'

    render_view(:form)
  end

  ##
  # Edits an existing user. If the specified user ID is invalid the user is
  # redirected back to the previous page.
  #
  # @author Yorick Peterse
  # @since  27-09-2011
  # @param  [Fixnum] id The ID of the user to edit.
  #
  def edit(id)
    @user = flash[:form_data] || User[id]

    if @user.nil?
      flash[:error] = 'The specified user is invalid'
      redirect_referrer
    end

    @title = "Edit #{@user.username}"

    render_view(:form)
  end

  ##
  # Saves the changes made by Users#new() and Users#edit(). Just like
  # Posts#save() this method is used for both methods since the actions required
  # for adding/updating the data is pretty much identical.
  #
  # @author Yorick Peterse
  # @since  27-09-2011
  #
  def save
    data = request.subset(:username, :password)
    id   = request.params['id']

    if !id.nil? and !id.empty?
      user = User[id]

      if user.nil?
        flash[:error] = 'The specified user is invalid'
        redirect_referrer
      end

      success = 'The user has been updated'
      error   = 'The user could not be updated'
    else
      user    = User.new
      success = 'The user has been added'
      error   = 'The user could not be added'
    end

    begin
      user.update(data)

      flash[:success] = success
      redirect(Users.r(:edit, user.id))
    rescue => e
      Ramaze::Log.error(e)

      flash[:error]       = error
      flash[:form_errors] = user.errors
      flash[:form_data]   = user

      redirect_referrer
    end
  end

  ##
  # Deletes a single user and redirects the user back to the overview.
  #
  # @author Yorick Peterse
  # @since  27-09-2011
  # @param  [Fixnum] id The ID of the user to delete.
  #
  def delete(id)
    begin
      User.filter(:id => id).destroy
      flash[:success] = 'The specified user has been removed'
    rescue => e
      Ramaze::Log.error(e)
      flash[:error] = 'The specified user could not be removed'
    end

    redirect_referrer
  end

  ##
  # Allows a user to log in. Once logged in the user is able to manage existing
  # users and edit posts.
  #
  # @author Yorick Peterse
  # @since  27-09-2011
  #
  def login
    if request.post?
      if user_login(request.subset('username', 'password'))
        flash[:success] = 'You have been logged in'
        redirect(Posts.r(:index))
      else
        flash[:error] = 'You could not be logged in'
      end
    end

    @title = 'Login'
  end

  ##
  # Logs the user out and destroys the session.
  #
  # @author Yorick Peterse
  # @since  27-09-2011
  #
  def logout
    user_logout
    session.clear
    flash[:success] = 'You have been logged out'
    redirect(Users.r(:login))
  end
end # Users
