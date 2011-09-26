##
# The Posts controller is used to display a list of all the posts that have been
# added as well as providing a way of adding, removing and updating posts.
#
# @author Yorick Peterse
# @since  26-09-2011
#
class Posts < BaseController
  map '/'

  # Sets the content type and view name based on the extension in the URL. For
  # example, a request to /posts/feed.rss would render the view feed.rss.xhtml
  # and set the content type to application/rss+xml.
  #provide(:rss , :type => 'application/rss+xml')
  #provide(:atom, :type => 'application/atom+xml')

  # These methods require the user to be logged in. If this isn't the case the
  # user will be redirected back to the previous page and a message is
  # displayed.
  before(:edit, :new, :save, :delete) do
    # "unless logged_in?" is the same as "if !logged_in?" but in my opinion is a
    # bit nicer to the eyes.
    unless logged_in?
      flash[:error] = 'You need to be logged in to view that page'

      # Posts.r() is a method that generates a route to a given method and a set
      # of parameters. Calling #to_s on this object would produce a string
      # containing a URL. For example, Posts.r(:edit, 10).to_s would result in
      # "/edit/10".
      redirect(Posts.r(:index))
    end
  end

  ##
  # Shows an overview of all the posts that have been added. These posts are
  # paginated using the Paginate helper.
  #
  # @author Yorick Peterse
  # @since  26-09-2011
  #
  def index
    @posts = paginate(Post.eager(:comments, :user))
    @title = 'Posts'
  end

  ##
  # Shows a single post along with all it's comments.
  #
  # @author Yorick Peterse
  # @since  26-09-2011
  # @param  [Fixnum] id The ID of the post to view.
  #
  def view(id)
    @post = Post[id]

    if @post.nil?
      flash[:error] = 'The specified post is invalid'
      redirect_referrer
    end

    @title = @post.title
  end

  ##
  # Allows a user to edit an existing blog post.
  #
  # @author Yorick Peterse
  # @since  26-09-2011
  # @param  [Fixnum] id The ID of the blog post to edit.
  #
  def edit(id)
    @post = Post[id]

    # Make sure the post is valid
    if @post.nil?
      flash[:error] = 'The specified post is invalid'
      redirect_referrer
    end

    @title = "Edit #{@post.title}"

    render_view :form
  end

  ##
  # Allows users to create a new post, given the user is logged in.
  #
  # @author Yorick Peterse
  # @since  26-09-2011
  #
  def new
    @post  = Post.new
    @title = 'New Post'

    render_view :form
  end

  ##
  # Saves the changes made by Posts#edit() and Posts#new(). While these two
  # methods could have their own methods for saving the data the entire process
  # is almost identical and thus this would be somewhat useless.
  #
  # @author Yorick Peterse
  # @since  26-09-2011
  #
  def save
    # Fetch the POST data to use for a new Post object or for updating an
    # existing one.
    data = request.subset(:title, :body)
    id   = request.params['id']

    # If an ID is given it's assumed the user wants to edit an existing post,
    # otherwise a new one will be created.
    if id
      post = Post[id]

      # Let's make sure the post is valid
      if post.nil?
        flash[:error] = 'The specified post is invalid'
        redirect_referrer
      end

      success = 'The post has been updated'
      error   = 'The post could not be updated'
    # Create a new post
    else
      post    = Post.new
      success = 'The post has been created'
      error   = 'The post could not be created'
    end

    # Now that we have a Post object and the messages to display it's time to
    # actually insert/update the data. This is wrapped in a begin/rescue block
    # so that any errors can be handled nicely.
    begin
      # Post#update() can be used for both new objects and existing ones. In
      # case the object doesn't exist in the database it will be automatically
      # created.
      post.update(data)

      flash[:success] = success

      # Redirect the user back to the correct page.
      redirect(Posts.r(:edit, post.id))
    rescue => e
      Ramaze::Log.error(e)

      # Store the submitted data and the errors. The errors are used by
      # BlueForm, the form data is used so that the user doesn't have to
      # re-enter all data every time something goes wrong.
      flash[:form_data]   = post
      flash[:form_errors] = post.errors
      flash[:error]       = error

      redirect_referrer
    end
  end

  ##
  # Deletes a number of posts using a POST array called "post_ids". This array
  # contains the IDs of the posts to remove.
  #
  # @author Yorick Peterse
  # @since  26-09-2011
  #
  def delete
    ids = request.params['post_ids']

    if ids.nil? or ids.empty?
      flash[:error] = 'You need to specify at least one post to remove'
      redirect_referrer
    end

    # The call is wrapped in a begin/rescue block so any errors can be handled
    # properly. Without this the user would bump into a nasty stack trace and
    # probably would have no clue as to what's going on.
    begin
      Post.filter(:id => ids).destroy
    rescue => e
      Ramaze::Log.error(e.message)
      flash[:error] = 'The specified posts could not be removed'

      redirect_referrer
    end

    flash[:success] = 'All specified posts have been removed'
    redirect_referrer
  end
end # Posts
