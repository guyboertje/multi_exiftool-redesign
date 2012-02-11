# coding: utf-8
require_relative 'helper'

describe "MultiExiftool::Writer" do

  before do
    @writer = MultiExiftool::Writer.new
  end

  describe 'command method' do

    it 'simple case' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      command = 'exiftool -author=janfri a.jpg b.tif c.bmp'
      @writer.command.must_equal command
    end

    it 'no filenames set' do
      @writer.values = {:author => 'janfri'}
      assert_raises MultiExiftool::OperationsError do
        @writer.command
      end
      @writer.filenames = []
      assert_raises MultiExiftool::OperationsError do
        @writer.command
      end
    end

    it 'no values set' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      assert_raises MultiExiftool::OperationsError do
        @writer.command
      end
      @writer.values = []
      assert_raises MultiExiftool::OperationsError do
        @writer.command
      end
    end

    it 'tags with spaces in values' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri', :comment => 'some comment'}
      command = 'exiftool -author=janfri -comment=some\ comment a.jpg b.tif c.bmp'
      @writer.command.must_equal command
    end

    it 'filenames with spaces' do
      @writer.filenames = ['one file with spaces.jpg', 'another file with spaces.tif']
      @writer.values = {:author => 'janfri'}
      command = 'exiftool -author=janfri one\ file\ with\ spaces.jpg another\ file\ with\ spaces.tif'
      @writer.command.must_equal command
    end

    it 'options with boolean argument' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      @writer.options = {:overwrite_original => true}
      command = 'exiftool -overwrite_original -author=janfri a.jpg b.tif c.bmp'
      @writer.command.must_equal command
    end

    it 'options with value argument' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      @writer.options = {:out => 'output_file'}
      command = 'exiftool -out output_file -author=janfri a.jpg b.tif c.bmp'
      @writer.command.must_equal command
    end

    it 'numerical flag' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      @writer.numerical = true
      command = 'exiftool -n -author=janfri a.jpg b.tif c.bmp'
      @writer.command.must_equal command
    end

    it 'overwrite_original flag' do
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {author: 'janfri'}
      @writer.overwrite_original = true
      command = 'exiftool -overwrite_original -author=janfri a.jpg b.tif c.bmp'
      @writer.command.must_equal command
    end

  end

  describe 'write method' do

    it 'succsessfull write' do
      mocking_open3('exiftool -author=janfri a.jpg b.tif c.bmp', '', '')
      @writer.filenames = %w(a.jpg b.tif c.bmp)
      @writer.values = {:author => 'janfri'}
      rc = @writer.write
      @writer.errors.must_equal []
      rc.must_equal true
    end

  end

end
