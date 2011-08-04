module Ramaze

  module Helper
  
    module UploadHelper
    
			# This method will iterate through all request parameters
			# and convert those parameters which represents uploaded
			# files to Ramaze::UploadedFile object. The matched parameters
			# will then be removed from the request parameter hash.
			#
			# If +pattern+ is given, only those request parameters which
			# has a name matching +pattern+ will be considered.
      def get_uploaded_files(pattern = nil)
				request.params.each_pair do |k, v|
					if pattern.nil? || pattern =~ k
						if is_uploaded_file?(v)
							self.uploaded_files[k] = Ramaze::UploadedFile.new(
								v[:filename], v[:type], v[:tempfile]
							)
							request.params.delete(k)
						end
					end
				end
      end

			# Add some class method whenever the helper is included
			# in a controller
			def self.included(mod)
				mod.extend(ClassMethods)
			end

			module ClassMethods
			
				# This method will activate automatic handling of uploaded files
				# for specified actions
				#
				# Ecach argument to this method can either be a symbol or an array
				# consisting of a symbol and a reqexp.
				# TODO: Explain more
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

			end
    
			def uploaded_files
				@uploaded_files ||= {}
				return @uploaded_files
			end
    
			private
			
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
    
    end
  
  end

	# This class represents an uploaded file
	class UploadedFile
	
		def initialize(filename, type, tempfile)
			@filename = filename
			@type = type
			@tempfile = tempfile
		end

		def save(dirname = nil, filename = nil)
			# Check if both filename and dirname is set and then save
		end
	
	end


end
