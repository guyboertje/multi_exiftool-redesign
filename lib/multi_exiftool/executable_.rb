# coding: utf-8
require 'open3'
require 'shellwords'

module MultiExiftool

  # Mixin for Reader and Writer.
  module Executable

    def execute # :nodoc:
      prepare_execution
      execute_command
      parse_results
    end
    
    alias read execute
    alias write execute

    private

    def prepare_execution
      @errors = []
    end

    def execute_command
      stdin, @stdout, @stderr = Open3.popen3(command)
    end

  end

end
