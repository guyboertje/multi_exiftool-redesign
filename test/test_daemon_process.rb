# coding: utf-8
require_relative 'helper'
require 'json'

describe "MultiExiftool::DaemonProcess" do

  before do
    @process = MultiExiftool::DaemonProcess.open
  end

  after do
    @process.close unless @process.closed?
  end

  describe "singleton initialization" do

    it 'is read to write' do
      assert @process.ready_to_write?
    end
    
    it "is not ready to read" do
      refute @process.ready_to_read?
    end

    it "is has no errors" do
      refute @process.errors?
    end
  end
  
  describe "exception raising" do
    
    before { @process.close }

    it "raises DaemonProcessClosed" do
      assert_raises MultiExiftool::DaemonProcessClosed do
        @process.write("")
      end
      assert_raises MultiExiftool::DaemonProcessClosed do
        @process.read.must_raise MultiExiftool::DaemonProcessClosed
      end
    end
    
    it "is closed" do
      assert @process.closed?
    end

  end

  describe "reading a resource" do

    it "reads metadata from a file" do

      @process.write(['-j', File.expand_path('./resources/id3v22-test.mp3')])

      assert @process.ready_to_read?

      meta = @process.read
      
      @process.errors.must_be_empty
      
      meta.wont_be_empty

      parsed_meta = JSON.parse(meta)

      parsed_meta.must_be_instance_of Array

      meta_hash = parsed_meta.first

      meta_hash["MIMEType"].must_equal "audio/mpeg"
      meta_hash["Title"].must_equal "cosmic american"
      meta_hash["Artist"].must_equal "Anais Mitchell"
      meta_hash["Album"].must_equal "Hymns for the Exiled"
      meta_hash["Track"].must_equal "3/11"

    end

  end
end
