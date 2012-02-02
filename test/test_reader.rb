# coding: utf-8
require_relative 'helper'

describe "MultiExiftool::Reader" do

  before do
    @reader = MultiExiftool::Reader.new
  end

  describe 'command method' do

    it 'simple case' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      command = 'exiftool -j a.jpg b.tif c.bmp'
      @reader.command.must_equal command
    end

    it 'no filenames' do
      assert_raises MultiExiftool::OperationsError do
        @reader.command
      end
      @reader.filenames = []
      assert_raises MultiExiftool::OperationsError do
        @reader.command
      end
    end

    it 'filenames with spaces' do
      @reader.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
      command = 'exiftool -j one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
      @reader.command.must_equal command
    end

    it 'tags' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.tags = %w(author fnumber)
      command = 'exiftool -j -author -fnumber a.jpg b.tif c.bmp'
      @reader.command.must_equal command
    end

    it 'options with boolean argument' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.options = {:e => true}
      command = 'exiftool -j -e a.jpg b.tif c.bmp'
      @reader.command.must_equal command
    end

    it 'options with value argument' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.options = {:lang => 'de'}
      command = 'exiftool -j -lang de a.jpg b.tif c.bmp'
      @reader.command.must_equal command
    end

    it 'numerical flag' do
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.numerical = true
      command = 'exiftool -j -n a.jpg b.tif c.bmp'
      @reader.command.must_equal command
    end

    it 'group flag' do
      @reader.filenames = %w(a.jpg)
      @reader.group = 0
      command = 'exiftool -j -g0 a.jpg'
      @reader.command.must_equal command
      @reader.group = 1
      command = 'exiftool -j -g1 a.jpg'
      @reader.command.must_equal command
    end

  end

  describe 'read method' do

    it 'try to read a non-existing file' do
      mocking_open3('exiftool -j non_existing_file', '', 'File non_existing_file not found.')
      @reader.filenames = %w(non_existing_file)
      res = @reader.read
      res.must_equal []
      @reader.errors.must_equal ['File non_existing_file not found.']
    end

    it 'successful reading with one tag' do
      json = <<-EOS
        [{
          "SourceFile": "a.jpg",
          "FNumber": 11.0
        },
        {
          "SourceFile": "b.tif",
          "FNumber": 9.0
        },
        {
          "SourceFile": "c.bmp",
          "FNumber": 8.0
        }]
      EOS
      json.gsub!(/^ {8}/, '')
      mocking_open3('exiftool -j -fnumber a.jpg b.tif c.bmp', json, '')
      @reader.filenames = %w(a.jpg b.tif c.bmp)
      @reader.tags = %w(fnumber)
      res =  @reader.read

      res.must_be_kind_of Array
      res.map {|e| e['FNumber']}.must_equal [11.0, 9.0, 8.0]
      @reader.errors.must_equal []
    end

    it 'successful reading of hierarichal data' do
      json = <<-EOS
        [{
          "SourceFile": "a.jpg",
          "EXIF": {
            "FNumber": 7.1
          },
          "MakerNotes": {
            "FNumber": 7.0
          }
        }]
      EOS
      json.gsub!(/^ {8}/, '')
      mocking_open3('exiftool -j -g0 -fnumber a.jpg', json, '')
      @reader.filenames = %w(a.jpg)
      @reader.tags = %w(fnumber)
      @reader.group = 0
      res =  @reader.read.first
      
      res.source_file.must_equal 'a.jpg'
      res.exif.fnumber.must_equal 7.1
      res.maker_notes.fnumber.must_equal 7.0
      @reader.errors.must_equal []
    end

  end

end
