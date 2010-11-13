require File.expand_path('../../../../lib/ramaze/helper/blue_form', __FILE__)

require 'bacon'
Bacon.summary_at_exit

describe BF = Ramaze::Helper::BlueForm do
  extend BF
  
  # Generate some dummy data
  @data = Class.new do
    attr_reader :username
    attr_reader :password
    attr_reader :assigned
    attr_reader :message
    attr_reader :servers_hash
    attr_reader :servers_array
    
    def initialize
      @username     = 'mrfoo'
      @password     = 'super-secret-password'
      @assigned     = 'bacon'
      @message      = 'Hello, textarea!'
      @servers_hash = {
        :webrick => 'WEBrick',
        :mongrel => 'Mongrel',
        :thin    => 'Thin',
      }
      @servers_array = ['WEBrick', 'Mongrel', 'Thin']
    end
  end.new

  # very strange comparision, sort all characters and compare, so we don't have
  # order issues.
  def assert(expected, output)
    left  = expected.to_s.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
    right = output.to_s.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
    left.scan(/./).sort.should == right.scan(/./).sort
  end
  
  # ------------------------------------------------
  # Basic forms

  it 'Make a basic form' do
    out = form @data, :method => :post
    assert(<<-FORM, out)
<form method="post"></form>
    FORM
  end

  it 'Make a form with the method and action attributes specified' do
    out = form(@data, :method => :post, :action => '/')
    assert(<<-FORM, out)
<form method="post" action="/"></form>
    FORM
  end

  it 'Make a form with a method, action and a name attribute' do
    out = form(@data, :method => :post, :action => '/', :name => :spec)
    assert(<<-FORM, out)
    <form method="post" action="/" name="spec">
    </form>
    FORM
  end

  it 'Make a form with a class and an ID' do
    out = form(@data, :class => :foo, :id => :bar)
    assert(<<-FORM, out)
    <form class="foo" id="bar">
    </form>
    FORM
  end

  it 'Make a form with a fieldset and a legend' do
    out = form(@data, :method => :get) do |f|
      f.g.fieldset do
        f.legend('The Form')
      end
    end
    
    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <legend>The Form</legend>
  </fieldset>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Text fields

  it 'Make a form with input_text(label, value)' do
    out = form(@data, :method => :get) do |f|
      f.input_text 'Username', :username
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-username">Username</label>
    <input type="text" name="username" id="form-username" value="mrfoo" />
  </p>
</form>
    FORM
  end
  
  it 'Make a form with input_text(username, label, value)' do
    out = form(@data, :method => :get) do |f|
      f.input_text 'Username', :username, :value => 'mrboo'
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-username">Username</label>
    <input type="text" name="username" id="form-username" value="mrboo" />
  </p>
</form>
    FORM
  end
  
  it 'Make a form with input_text(label, name, size, id)' do
    out = form(@data, :method => :get) do |f|
      f.input_text 'Username', :username, :size => 10, :id => 'my_id'
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="my_id">Username</label>
    <input size="10" type="text" name="username" id="my_id" value="mrfoo" />
  </p>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Password fields
  
  it 'Make a form with input_password(label, name)' do
    out = form(nil , :method => :get) do |f|
      f.input_password 'Password', :password
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-password">Password</label>
    <input type="password" name="password" id="form-password" />
  </p>
</form>
    FORM
  end
  
  it 'Make a form with input_password(label, name, value, class)' do
    out = form(@data, :method => :get) do |f|
      f.input_password 'Password', :password, :value => 'super-secret-password', :class => 'password_class'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-password">Password</label>
    <input class="password_class" type="password" name="password" id="form-password" value="super-secret-password" />
  </p>
</form>   
    FORM
  end
  
  # ------------------------------------------------
  # Submit buttons
  
  it 'Make a form with input_submit()' do
    out = form(@data, :method => :get) do |f|
      f.input_submit
    end
    
    assert(<<-FORM, out)
<form method="get">
    <p>
      <input type="submit" />
    </p>
</form>
    FORM
  end

  it 'Make a form with input_submit(value)' do
    out = form(@data, :method => :get) do |f|
      f.input_submit 'Send'
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <input type="submit" value="Send" />
  </p>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Checkboxes
  
  it 'Make a form with input_checkbox(label, name)' do
    out = form(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, true
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-assigned">Assigned</label>
    <input type="hidden" name="assigned" value="0" />
    <input type="checkbox" name="assigned" id="form-assigned" checked="checked" value="bacon" />
  </p>
</form>
    FORM
  end

  it 'Make a form with input_checkbox(label, name, checked = false)' do
    out = form(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, false
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-assigned">Assigned</label>
    <input type="hidden" name="assigned" value="0" />
    <input type="checkbox" name="assigned" id="form-assigned" value="bacon" />
  </p>
</form>
    FORM
  end

  it 'Make a form with input_checkbox(label, name, checked = true)' do
    out = form(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, true, :value => 'boo', :default => 'ramaze'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-assigned">Assigned</label>
    <input type="hidden" name="assigned" value="ramaze" />
    <input type="checkbox" name="assigned" id="form-assigned" checked="checked" value="boo" />
  </p>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Radio buttons
  
  it 'Make a form with input_radio(label, name)' do
    out = form(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned, true
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-assigned">Assigned</label>
    <input type="hidden" name="assigned" value="0" />
    <input type="radio" name="assigned" id="form-assigned" checked="checked" value="bacon" />
  </p>
</form>
    FORM
  end

  it 'Make a form with input_radio(label, name, checked = false)' do
    out = form(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned, false
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-assigned">Assigned</label>
    <input type="hidden" name="assigned" value="0" />
    <input type="radio" name="assigned" id="form-assigned" value="bacon" />
  </p>
</form>
    FORM
  end

  it 'Make a form with input_radio(label, name, checked = true)' do
    out = form(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned, true, :value => 'boo', :default => 'ramaze'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-assigned">Assigned</label>
    <input type="hidden" name="assigned" value="ramaze" />
    <input type="radio" name="assigned" id="form-assigned" checked="checked" value="boo" />
  </p>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # File uploading
  
  it 'Make a form with input_file(label, name)' do
    out = form(@data, :method => :get) do |f|
      f.input_file 'File', :file
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-file">File</label>
    <input type="file" name="file" id="form-file" />
  </p>
</form>
    FORM
  end

  it 'Make a form with input_file(label, name)' do
    out = form(@data, :method => :get) do |f|
      f.input_file 'File', :file, :id => 'awesome_file'
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="awesome_file">File</label>
    <input type="file" name="file" id="awesome_file" />
  </p>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Hidden fields
  
  it 'Make a form with input_hidden(name, value)' do
    out = form(@data, :method => :get) do |f|
      f.input_hidden :username, 'Bob Ross'
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="Bob Ross" />
</form>
    FORM
  end
  
  it 'Make a form with input_hidden(name, value, id)' do
    out = form(@data, :method => :get) do |f|
      f.input_hidden :username, 'Bob Ross', :id => 'test'
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="Bob Ross" id="test" />
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Textarea elements
  
  it 'Make a form with textarea(label, name)' do
    out = form(@data, :method => :get) do |f|
      f.textarea 'Message', :message
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-message">Message</label>
    <textarea name="message" id="form-message">Hello, textarea!</textarea>
  </p>
</form>
    FORM
  end

  it 'Make a form with textarea(label, name, value)' do
    out = form(@data, :method => :get) do |f|
      f.textarea 'Message', :message, :value => 'stuff'
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-message">Message</label>
    <textarea name="message" id="form-message">stuff</textarea>
  </p>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Select elements

  it 'Make a form with select(label, name) from a hash' do
    out = form(@data, :method => :get) do |f|
      f.select 'Server', :servers_hash
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-servers-hash">Server</label>
    <select id="form-servers-hash" size="1" name="servers_hash">
      <option value="webrick">WEBrick</option>
      <option value="mongrel">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it 'Make a form with select(label, name, selected) from a hash' do
    out = form(@data, :method => :get) do |f|
      f.select 'Server', :servers_hash, :selected => :mongrel
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-servers-hash">Server</label>
    <select id="form-servers-hash" size="1" name="servers_hash">
      <option value="webrick">WEBrick</option>
      <option value="mongrel" selected="selected">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end
  
  it 'Make a form with select(label, name) from an array' do
    out = form(@data, :method => :get) do |f|
      f.select 'Server', :servers_array
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-servers-array">Server</label>
    <select id="form-servers-array" size="1" name="servers_array">
      <option value="WEBrick">WEBrick</option>
      <option value="Mongrel">Mongrel</option>
      <option value="Thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it 'Make a form with select(label, name, selected) from an array' do
    out = form(@data, :method => :get) do |f|
      f.select 'Server', :servers_array, :selected => 'Mongrel'
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-servers-array">Server</label>
    <select id="form-servers-array" size="1" name="servers_array">
      <option value="WEBrick">WEBrick</option>
      <option value="Mongrel" selected="selected">Mongrel</option>
      <option value="Thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Select elements with custom values
  
  it 'Make a form with select(label, name) from a hash using custom values' do
    out = form(@data, :method => :get) do |f|
      f.select 'People', :people_hash, :values => {:chuck => 'Chuck', :bob => 'Bob'}
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-people-hash">People</label>
    <select id="form-people-hash" size="1" name="people_hash">
      <option value="chuck">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it 'Make a form with select(label, name, selected) from a hash using custom values' do
    out = form(@data, :method => :get) do |f|
      f.select 'People', :people_hash, :values => {:chuck => 'Chuck', :bob => 'Bob'}, :selected => :chuck
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-people-hash">People</label>
    <select id="form-people-hash" size="1" name="people_hash">
      <option value="chuck" selected="selected">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end
  
  it 'Make a form with select(label, name) from an array using custom values' do
    out = form(@data, :method => :get) do |f|
      f.select 'People', :people_array, :values => ['Chuck', 'Bob']
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-people-array">People</label>
    <select id="form-people-array" size="1" name="people_array">
      <option value="Chuck">Chuck</option>
      <option value="Bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it 'Make a form with select(label, name, selected) from an array using custom values' do
    out = form(@data, :method => :get) do |f|
      f.select 'People', :people_array, :values => ['Chuck', 'Bob'], :selected => 'Chuck'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-people-array">People</label>
    <select id="form-people-array" size="1" name="people_array">
      <option value="Chuck" selected="selected">Chuck</option>
      <option value="Bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end
  
  # ------------------------------------------------
  # Error messages

  it 'Insert an error message' do
    form_error :username, 'May not be empty'
    out = form(@data, :method => :get) do |f|
      f.input_text 'Username', :username
    end
    
    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form-username">Username <span class="error">May not be empty</span></label>
    <input type="text" name="username" id="form-username" value="mrfoo" />
  </p>
</form>
    FORM
  end


end
