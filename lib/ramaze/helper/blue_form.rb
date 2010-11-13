require 'ramaze'
require 'ramaze/gestalt'

module Ramaze
  module Helper
    ##
    # == Introduction
    # 
    # The BlueForm helper tries to be an even better way to build forms programmatically.
    # By using a simple block you can quickly create all the required elements for your form.
    #
    # Since November 2010 the BlueForm helper works different. You can now specify an object as the first
    # parameter of the form() method. This object will be used to retrieve the values of each field.
    # This means that you can directly pass a database result object to the form and no longer have
    # to manually specify values. However, you can still specify your own values if you want.
    #
    # Old behaviour:
    #
    #  form(:method => :post) do |f|
    #    f.input_text 'Username', :username, 'Chuck Norris'
    #  end
    #
    # New behaviour:
    #
    #  # @data is an object that contains an instance variable named "username".
    #  # This variable contains the value "Chuck Norris".
    #  form(@data, :method => :post) do |f|
    #    f.input_text 'Username', :username
    #  end
    #
    # == Form Data
    #
    # As stated earlier it's possible to pass an object to the form() method. What kind of object this is,
    # a database result object or an OpenStruct object doesn't matter as long as the attributes can be accessed
    # outside of the object (this can be done using attr_readers). This makes it extremely easy to directly pass
    # a result object from your favourite ORM. Example:
    #
    #  @data = User[1]
    #
    #  form(@data, :method => :post) do |f|
    #    f.input_text 'Username', :username
    #  end
    #
    # If you don't want to use an object you can simply set the first parameter to nil.
    #
    # == HTML Output
    # 
    # The form helper uses Gestalt, Ramaze's custom HTML builder that works somewhat like Erector.
    # The output is very minimalistic, elements such as legends and fieldsets have to be added manually.
    # Each combination of a label and input element will be wrapped in <p> tags.
    #
    # When using the form helper as a block in your templates it's important to remember that the
    # result is returned and not displayed in the browser directly. When using Etanni this would result in
    # something like the following:
    #
    #  #{
    #    form(@result, :method => :post) do |f| do
    #      f.input_text 'Text label', :textname, 'Chunky bacon!'
    #    end
    #  }
    # 
    # @example
    #
    #  form(@data, :method => :post) do |f|
    #    f.input_text 'Username', :username
    #  end
    #
    module BlueForm
      ##
      # The form method generates the basic structure of the form. It should be called
      # using a block and it's return value should be manually sent to the browser (since it does not echo the value).
      #
      # @param [Object] form_values Object containing the values for each form field.
      # @param [Hash] options Hash containing any additional form attributes such as the method, action, enctype and so on.
      # @param [Block] block Block containing the elements of the form such as password fields, textareas and so on. 
      #
      def form(form_values, options = {}, &block)
        form = Form.new(form_values, options)
        form.build(form_errors, &block)
        form
      end

      ##
      # Manually add a new error to the form_errors key in the flash hash.
      # The first parameter is the name of the form field and the second parameter is the custom message.
      #
      # @param [String] name The name of the form field to which the error belongs.
      # @param [String] message The custom error message to show.
      #
      def form_error(name, message)
        if respond_to?(:flash)
          old = flash[:form_errors] || {}
          flash[:form_errors] = old.merge(name.to_s => message.to_s)
        else
          form_errors[name.to_s] = message.to_s
        end
      end

      ##
      # Display all form errors.
      #
      def form_errors
        if respond_to?(:flash)
          flash[:form_errors] ||= {}
        else
          @form_errors ||= {}
        end
      end

      ##
      # Retrieve all the form errors for the specified model and add them to the flash hash.
      #
      # @param [Object] obj An object of a model that contains form errors.
      #
      def form_errors_from_model(obj)
        obj.errors.each do |key, value|
          form_error(key.to_s, value.first % key)
        end
      end

      ##
      # Main form class that contains all the required methods to generate form specific tags,
      # such as textareas and select boxes. Do note that this class is not thread-safe so you should
      # modify it only within one thread of execution.
      #
      class Form
        attr_reader :g
        attr_reader :form_values

        ##
        # Constructor method that generates an instance of the Form class.
        #
        # @param [Object] form_values Object containing the values for each form field.
        # @param [Hash] options A hash containing any additional form attributes.
        # @return [Object] An instance of the Form class.
        #
        def initialize(form_values, options)
          @form_values  = form_values
          @form_args    = options.dup
          @g            = Gestalt.new
        end

        ##
        # Builds the form by generating the opening/closing tags and executing
        # the methods in the block.
        #
        # @param [Hash] form_errors Hash containing all form errors (if any).
        #
        def build(form_errors = {})
          @form_errors = form_errors

          @g.form(@form_args) do
            if block_given?
              yield self
            end
          end
        end

        ##
        # Generate a <legend> tag.
        #
        # @param [String] text The text to display inside the legend tag.
        # @example
        # 
        #   form(:method => :post) do |f|
        #     f.legend 'Ramaze rocks!'
        #   end
        #
        def legend(text)
          @g.legend(text)
        end

        ##
        # Generate an input tag with a type of "text" along with a label tag.
        # This method also has the alias "text" so feel free to use that one instead of input_text.
        # 
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the text field.
        # @param [Hash] args Any additional HTML attributes along with their values.
        # @example
        #
        #   form(:method => :post) do |f|
        #     f.input_text 'Username', :username, :id => 'str_username', :style => 'border: 1px solid pink;'
        #   end
        #
        def input_text(label, name, args = {})
          # The ID can come from 2 places, id_for and the args hash
          id   = args[:id] ? args[:id] : id_for(name)
          args = args.merge(:type => :text, :name => name, :id => id)

          if !args[:value] and @form_values.respond_to?(name)
            args[:value] = @form_values.send(name)
          end

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias text input_text

        ##
        # Generate an input tag with a type of "password" along with a label.
        # Password fields are pretty much the same as text fields except that the content of these fields is replaced with dots.
        # This method has the following alias: "password".
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the password field.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def input_password(label, name, args = {})
          # The ID can come from 2 places, id_for and the args hash
          id   = args[:id] ? args[:id] : id_for(name)
          args = args.merge(:type => :password, :name => name, :id => id)
          
          if !args[:value] and @form_values.respond_to?(name)
            args[:value] = @form_values.send(name)
          end
          
          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias password input_password

        ##
        # Generate a submit tag (without a label). A submit tag is a button that once it's clicked
        # will send the form data to the server.
        #
        # @param [String] value The text to display in the button.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def input_submit(value = nil, args = {})
          args         = args.merge(:type => :submit)
          args[:value] = value unless value.nil?

          @g.p do
            @g.input(args)
          end
        end
        alias submit input_submit

        ##
        # Generate an input tag with a type of "checkbox". This method will also
        # generate a hidden field with the same name as the checkbox to ensure
        # that the data is always submitted.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the checkbox.
        # @param [Bool] checked Boolean that indicates if the checkbox is checked or not.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def input_checkbox(label, name, checked = false, args = {})
          id = args[:id] ? args[:id] : id_for(name)

          # Get the default value for the checkbox used for the hidden field.
          if args[:default]
            default = args[:default]
            args.delete(:default)
          else
            default = 0
          end

          # Parse the additional arguments
          args            = args.merge(:type => :checkbox, :name => name, :id => id)
          args[:checked]  = 'checked' if checked
          
          if !args[:value] and @form_values.respond_to?(name)
            args[:value] = @form_values.send(name)
          end

          @g.p do
            label_for(id, label, name)
            self.input_hidden(name, default)
            @g.input(args)
          end
        end
        alias checkbox input_checkbox

        ##
        # Generate an input tag with a type of "radio". This method will also
        # generate a hidden field with the same name as the radio button to ensure
        # that the data is always submitted.
        #
        # Please note that you can no longer use an array or hash to generate multiple
        # radio buttons. This method has been removed since <select> tags are better
        # for that type of behaviour.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the radio tag.
        # @param [Bool] checked Boolean that indicates if the checkbox is checked or not.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def input_radio(label, name, checked, args = {})
          id = args[:id] ? args[:id] : id_for(name)

          # Get the default value for the radio used for the hidden field.
          if args[:default]
            default = args[:default]
            args.delete(:default)
          else
            default = 0
          end

          # Parse the additional arguments
          args            = args.merge(:type => :radio, :name => name, :id => id)
          args[:checked]  = 'checked' if checked
          
          if !args[:value] and @form_values.respond_to?(name)
            args[:value] = @form_values.send(name)
          end

          @g.p do
            label_for(id, label, name)
            self.input_hidden(name, default)
            @g.input(args)
          end
        end
        alias radio input_radio

        ##
        # Generate a field for uploading files.
        # 
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the radio tag.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def input_file(label, name, args = {})
          id   = args[:id] ? args[:id] : id_for(name)
          args = args.merge(:type => :file, :name => name, :id => id)

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias file input_file

        ##
        # Generate a hidden field. Hidden fields are essentially the same as text fields
        # except that they aren't displayed in the browser.
        #
        # @param [String Symbol] name The name of the hidden field tag.
        # @param [String] value The value of the hidden field
        # @param [Hash] args Any additional HTML attributes along with their values.
        # 
        def input_hidden(name, value = nil, args = {})
          args = args.merge(:type => :hidden, :name => name)
          
          if !value and @form_values.respond_to?(name)
            args[:value] = @form_values.send(name)
          else
            args[:value] = value
          end

          @g.input(args)
        end
        alias hidden input_hidden

        ##
        # Generate a text area.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the textarea.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def textarea(label, name, args = {})
          id = args[:id] ? args[:id] : id_for(name)
          
          # Get the value of the textarea
          if !args[:value] and @form_values.respond_to?(name)
            value = @form_values.send(name)
          else
            value = args[:value]
            args.delete(:value)
          end
          
          args = args.merge(:name => name, :id => id)

          @g.p do
            label_for(id, label, name)
            @g.textarea(args){ value }
          end
        end

        ##
        # Generate a select tag along with the option tags and a label.
        # 
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the select tag.
        # @param [Hash] args Hash containing additional HTML attributes.
        #
        def select(label, name, args = {})
          id              = args[:id] ? args[:id] : id_for(name)
          multiple, size  = args.values_at(:multiple, :size)

          args[:multiple] = 'multiple' if multiple
          args[:size]     = (size || multiple || 1).to_i
          args[:name]     = multiple ? "#{name}[]" : name
          args            = args.merge(:id => id)
          
          # Get all the values
          if !args[:values] and @form_values.respond_to?(name)
            values = @form_values.send(name)
          else
            values = args[:values]
            args.delete(:values)
          end

          # Retrieve the selected value
          has_selected, selected = args.key?(:selected), args[:selected]
          args.delete(:selected)

          @g.p do
            label_for(id, label, name)
            @g.select args do
              values.each do |value, o_name|
                o_name ||= value
                o_args = {:value => value}
                o_args[:selected] = 'selected' if has_selected && value == selected
                @g.option(o_args){ o_name }
              end
            end
          end
        end

        ##
        # Method used for converting the results of the BlueForm helper to a string
        #
        # @return [String] The form output
        #
        def to_s
          @g.to_s
        end

        private

        ##
        # Generate a label based on the id and value.
        #
        # @param [String] id The ID to which the label belongs.
        # @param [String] value The text to display inside the label tag.
        # @param [String] name The name of the field to which the label belongs.
        #
        def label_for(id, value, name)
          if error = @form_errors.delete(name.to_s)
            @g.label("#{value} ", :for => id){ @g.span(:class => :error){ error } }
          else
            @g.label(value, :for => id)
          end
        end

        ##
        # Generate a value for an ID tag based on the field's name.
        #
        # @param  [String] field_name The name of the field.
        # @return [String] The ID for the specified field name.
        #
        def id_for(field_name)
          if name = @form_args[:name]
            "#{name}-#{field_name}".downcase.gsub(/_/, '-')
          else
            "form-#{field_name}".downcase.gsub(/_/, '-')
          end
        end
      end
    end
  end
end
