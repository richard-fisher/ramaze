require File.expand_path('../../../../spec/helper', __FILE__)
require 'fileutils'

class SpecUploadHelper < Ramaze::Controller
  map '/'

  helper :upload

  def empty
    if get_uploaded_files.empty?
      return 'empty'
    else
      return 'not empty'
    end
  end

  def upload
    get_uploaded_files.each_pair do |k, v|
      v.save(File.join('/tmp/ramaze_uploads', v.filename))

      return 'not uploaded' unless v.saved?
    end

    return 'uploaded'
  end
end

describe('Ramaze::Helper::Upload') do
  behaves_like :rack_test

  # Ensure the upload directory exists
  before do
    Dir.mkdir('/tmp/ramaze_uploads')
  end

  # And remove the directory after each run
  after do
    FileUtils.rm_rf('/tmp/ramaze_uploads')
  end

  it('No files should be uploaded') do
    get('/empty').body.strip.should === 'empty'
  end

  it('Upload a text file') do
    file = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_1.txt'),
      'text/plain'
    )

    body = post('/upload', :file_1 => file).body.strip

    body.should === 'uploaded'

    File.exist?('/tmp/ramaze_uploads/text_1.txt').should     === true
    File.read('/tmp/ramaze_uploads/text_1.txt').strip.should === 'Hello world'
  end

  it('Upload multiple files') do
    file_1 = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_1.txt'),
      'text/plain'
    )

    file_2 = Rack::Test::UploadedFile.new(
      __DIR__('uploads/text_2.txt'),
      'text/plain'
    )

    body = post('/upload', :file_1 => file_1, :file_2 => file_2).body.strip

    body.should === 'uploaded'

    File.exist?('/tmp/ramaze_uploads/text_1.txt').should     === true
    File.read('/tmp/ramaze_uploads/text_1.txt').strip.should === 'Hello world'

    File.exist?('/tmp/ramaze_uploads/text_2.txt').should     === true
    File.read('/tmp/ramaze_uploads/text_2.txt').strip.should === 'Hello Ramaze'
  end
end
