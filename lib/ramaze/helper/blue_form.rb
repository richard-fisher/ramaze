require 'ramaze'
require 'ramaze/gestalt'

module Ramaze
  module Helper
    ##
    # The BlueForm helper tries to be an even better way to build forms programmatically.
    # By using a simple block you can quickly create all the required elements for your form.
    # 
    # When using the form helper as a block in your templates it's important to remember that the
    # result is returned and not displayed in the browser. This means you'll have to output the results
    # yourself. When using Etanni this would result in something like the following:
    #
    # #{
    #   form(:method => :post) do |f| do
    #     f.input_text 'Text label', :textname, 'Chunky bacon!'
    #   end
    # }
    # 
    # @example
    #
    #   form(:method => :post) do |f|
    #     f.input_text 'This is the label of the text input', :name, 'The value goes in here'
    #   end
    #
    module BlueForm
      ##
      # The form method generates the basic structure of the form. It should be called
      # using a block and it's return value should be manually sent to the browser (since it does not echo the value).
      #
      # @param [Hash] options Hash containing any additional form attributes such as the method, action, enctype and so on.
      # @param [Block] block Block containing the elements of the form such as password fields, textareas and so on. 
      #
      def form(options = {}, &block)
        form = Form.new(options)
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
      # @todo Describe the form_errors method since I (Yorick) am not too sure what it does.
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

        ##
        # Constructor method that generates an instance of the Form class.
        #
        # @param [Hash] options A hash containing any additional form attributes.
        # @return [Object] An instance of the Form class.
        #
        def initialize(options)
          @form_args = options.dup
          @g = Gestalt.new
        end

        ##
        # Generate the form output.
        #
        # @param [Hash] form_errors Hash containing all form errors (if any).
        # @todo Imrpove the docs of this method since I (Yorick) am not entirely sure what it does.
        #
        def build(form_errors = {})
          @form_errors = form_errors

          @g.form(@form_args) do
            if block_given?
              @g.fieldset do
                yield self
              end
            end
          end
        end

        ##
        # Generate a <legend> tag.
        #
        # @param [String] text The text to display inside the legend tag.
        # @example
        # 
        # form(:method => :post) do |f|
        #   f.legend 'Ramaze rocks!'
        # end
        #
        def legend(text)
          @g.legend(text)
        end

        ##
        # Generate an input tag with a type of "text" along with a label tag.
        # This method also has the alias "text" so feel free to use that one instead of input_text.
        # 
        # @param [String] label The text to display inside the label tag.
        # @param [String/Symbol] name The name of the text field.
        # @param [String] value The value of the text field.
        # @param [Hash] args Any additional HTML attributes along with their values.
        # @example
        #
        #   form(:method => :post) do |f|
        #     f.input_text 'Username', :username, 'Yorick Peterse', :id => 'str_username', :style => 'border: 1px solid pink;'
        #   end
        #
        def input_text(label, name, value = nil, args = {})
          id           = id_for(name)
          args         = args.merge(:type => :text, :name => name, :id => id)
          args[:value] = value unless value.nil?

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias text input_text

        ##
        # Generate an input tag with a type of "password" along with a label.
        # Password fields are pretty much the same as text fields except that the content of these fields is replaced with dots.
        #
        # This method has the following alias: "password".
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String/Symbol] name The name of the password field.
        # @param [String] value The value of the password field.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def input_password(label, name, value = nil, args = {})
          id           = id_for(name)
          args         = args.merge(:type => :password, :name => name, :id => id)
          args[:value] = value unless value.nil?

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
        # This method has the following alias: "submit".
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
        # Generate an input tag with a type of "checkbox".
        #
        # This method has the following alias: "checkbox".
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String/Symbol] name The name of the checkbox.
        # @param [Bool] checked Boolean that indicates if the checkbox is checked or not.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def input_checkbox(label, name, checked = false, args = {})
          id = id_for(name)
          args = {:type => :checkbox, :name => name, :id => id}
          args[:checked] = 'checked' if checked

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias checkbox input_checkbox

        ##
        # Generate an input tag with a type of "radio".
        #
        # This method has the following alias: "radio".
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String/Symbol] name The name of the radio tag.
        # @param [Array] values Array containing the values for each radio tag.
        # @param [Hash] options Any additional HTML attributes along with their values.
        #
        def input_radio(label, name, values, options = {})
          has_checked, checked = options.key?(:checked), options[:checked]

          @g.p do
            values.each_with_index do |(value, o_name), index|
              o_name ||= value
              id = id_for("#{name}-#{index}")

              o_args = {:type => :radio, :value => value, :id => id, :name => name}
              o_args[:checked] = 'checked' if has_checked && value == checked

              if error = @form_errors.delete(name.to_s)
                @g.label(:for => id){
                  @g.span(:class => :error){ error }
                  @g.input(o_args)
                  @g.out << o_name
                }
              else
                @g.label(:for => id){
                  @g.input(o_args)
                  @g.out << o_name
                }
              end
            end
          end
        end
        alias radio input_radio

        ##
        # Generate a field for uploading files.
        #
        # This method has the following alias: "file".
        # 
        # @param [String] label The text to display inside the label tag.
        # @param [String/Symbol] name The name of the radio tag.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def input_file(label, name, args = {})
          id   = id_for(name)
          args = args.merge(:type => :file, :name => name, :id => id)

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias file input_file

        ##
        # Generate a hidden field. Hidden fields are essentially the same as text fields except that they aren't displayed
        # in the browser.
        #
        # This method has the following alias: "hidden".
        #
        # @param [String/Symbol] name The name of the hidden field tag.
        # @param [String] value The value of the hidden field
        # @param [Hash] args Any additional HTML attributes along with their values.
        # 
        def input_hidden(name, value = nil, args = {})
          args         = args.merge(:type => :hidden, :name => name)
          args[:value] = value.to_s unless value.nil?

          @g.input(args)
        end
        alias hidden input_hidden

        ##
        # Generate a text area.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String/Symbol] name The name of the textarea.
        # @param [String] value The value of the textarea.
        # @param [Hash] args Any additional HTML attributes along with their values.
        #
        def textarea(label, name, value = nil, args = {})
          id   = id_for(name)
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
        # @param [String/Symbol] name The name of the select tag.
        # @param [Array] values Array containing the values for each option tag.
        # @param [Hash] options Hash containing additional HTML attributes.
        #
        def select(label, name, values, options = {})
          id             = id_for(name)
          multiple, size = options.values_at(:multiple, :size)

          args = {:id => id}
          args[:multiple] = 'multiple' if multiple
          args[:size] = (size || multiple || 1).to_i
          args[:name] = multiple ? "#{name}[]" : name

          has_selected, selected = options.key?(:selected), options[:selected]

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
        # @param [String] field_name The name of the field.
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
