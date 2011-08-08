module Ramaze

  module Helper

    # Helper module for handling file uploads. File uploads are mostly handled
    # by Rack, but this helper adds some conveniance methods for handling
    # and saving the uploaded files.
    module UploadHelper
      
      include Innate::Traited
      
      # Assume that no files have been uploaded by default
      trait :default_uploaded_files => Hash.new

      # This method will iterate through all request parameters
      # and convert those parameters which represents uploaded
      # files to Ramaze::UploadedFile object. The matched parameters
      # will then be removed from the request parameter hash.
      #
      # If +pattern+ is given, only those request parameters which
      # has a name matching +pattern+ will be considered.
      #
      # Use this method if you want to decide whether to handle file uploads
      # in your action at runtime. For automatic handling, use
      # Ramaze::Helper::UploadHelper::ClassMethods::handle_uploads_for or
      # Ramaze::Helper::UploadHelper::ClassMethods::handle_all_uploads instead
      #
      def get_uploaded_files(pattern = nil)
        uploaded_files = {}
        request.params.each_pair do |k, v|
          if pattern.nil? || pattern =~ k
            if is_uploaded_file?(v)
              uploaded_files[k] = Ramaze::UploadedFile.new(
                v[:filename],
                v[:type],
                v[:tempfile],
                ancestral_trait[:upload_options] || ancestral_trait[:default_upload_options]
              )
              request.params.delete(k)
            end
          end
        end

        # If at least one file upload matched, override the uploaded_files
        # method with a singleton method that returns the list of uploaded
        # files. Doing things this way allows us to store the list of uploaded
        # files without using an instance variable.
        unless uploaded_files.empty?
          metaclass = class << self; self; end
          metaclass.instance_eval do
            define_method :uploaded_files do
              return uploaded_files
            end
          end
          # Save uploaded files if autosave is set to true
          if ancestral_trait[:upload_options] && ancestral_trait[:upload_options][:autosave]
            uploaded_files.each_value do |uf|
              uf.save
            end
          end
        end
      end

      # :nodoc:
      # Add some class method whenever the helper is included
      # in a controller
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # Return list of currently handled file uploads
      def uploaded_files
        return Innate::Helper::UploadHelper.trait[:default_uploaded_files]
      end

      private

      # Returns whether +param+ is considered an uploaded file
      # A parameter is considered to be an uploaded file if it is
      # a hash and contains all parameters that Rack assigns to an
      # uploaded file
      #
      def is_uploaded_file?(param)
        if param.is_a?(Hash) &&
          param.has_key?(:filename) &&
          param.has_key?(:type) &&
          param.has_key?(:name) &&
          param.has_key?(:tempfile) &&
          param.has_key?(:head)
          return true
        else
          return false
        end
      end
      
      # Helper class methods. Methods in this module will be available
      # in your controller *class* (not your controller instance).
      module ClassMethods
        include Innate::Traited
        # Default options for uploaded files. You can affect these options
        # by using the uploads_options method
        trait :default_upload_options => {
          :allow_overwrites => false,
          :autosave => false,
          :default_upload_dir => nil
        }
        
        # This method will activate automatic handling of uploaded files
        # for specified actions
        #
        # Each argument to this method can either be a symbol or an array
        # consisting of a symbol and a reqexp.
        #
        # Example usage:
        #
        # * Handle all uploads for the foo and bar actions
        # handle_uploads_for :foo, :bar
        #
        # * Handle all uploads for the foo action and uploads beginning with
        #   'up' for the bar action
        # handle_uploads_for :foo, [:bar, /^up/]
        #
        def handle_uploads_for(*args)
          args.each do |arg|
            if arg.is_a?(Array)
              before(arg.first.to_sym) do
                get_uploaded_files(arg.last)
              end
            else
              before(arg.to_sym) do
                get_uploaded_files
              end
            end
          end
        end

        # This method will activate automatic handling of uploaded files
        # for *all* actions in the controller
        #
        # If +pattern+ is given, only those request parameters which match
        # +pattern+ will be considered for automatic handling
        def handle_all_uploads(pattern = nil)
          before_all do
            get_uploaded_files(pattern)
          end
        end
        
        # Set options for uploads
        def upload_options(hsh)
          options = Innate::Helper::UploadHelper::ClassMethods.trait[:default_upload_options].merge(hsh)
          trait :upload_options => options
        end
        
      end
    end

  end

  # This class represents an uploaded file
  class UploadedFile

    # Initializes a new Ramaze::UploadedFile object
    def initialize(filename, type, tempfile, options)
      @filename = filename
      @type = type
      @tempfile = tempfile
      @options = options
    end

    # Save file
    def save(dirname = nil, filename = nil)
      # Check that dirname is set
      dn = dirname || @options[:default_upload_dir]
      raise Exception.new('Unable to save file, no dirname given') unless dn     
      # Check that filename is set
      fn = filename || @filename
      raise Exception.new('Unable to save file, no filename given') unless fn
      
      # Build path
      path = File.absolute_path(File.join(dn, fn))
      # Abort if file altready exists and overwrites are not allowed
      raise Exception.new('Unable to overwrite existing file') if File.exists?(path) && !@options[:allow_overwrites]
      # Confirm that we can read source file
      raise Exception.new('Unable to read temporary file') unless File.readable?(@tempfile)
      # Confirm that we can write to the destination file
      raise Exception.new("Unable to save file to #{path}. Path is not writable") unless (File.exists?(path) && File.writable?(path)) || File.writable?(File.dirname(path))
      File.open(@tempfile, 'rb') do |source|
        File.open(path, 'wb') do |dest|
          dest.write(source.read)
        end
      end
    end

  end

end
