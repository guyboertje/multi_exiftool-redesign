# coding: utf-8
require 'open3'

module MultiExiftool

  # Mixin for Reader and Writer.
  module Executable

    def self.extended other
      if other.class.name == "Reader"
        alias read execute
      end
      if other.class.name == "Writer"
        alias write execute
      end
    end

    def execute # :nodoc:
      prepare_execution
      execute_command
      parse_results
    end

    def command
      cmd = [exiftool_command]
      cmd << options_args
      cmd << tags_args
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    private
    
    def prepare_execution
      @errors = []
    end

    def execute_command
      stdin, @stdout, @stderr = Open3.popen3(command)
    end

  end

end
