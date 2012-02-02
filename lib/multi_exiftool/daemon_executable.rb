# coding: utf-8
require 'open3'

module MultiExiftool

  # Mixin for Reader and Writer.
  module DaemonExecutable

    def self.extended other
      puts "class extended by #{other}"  
    end

    def execute # :nodoc:
      prepare_execution
      execute_command
      parse_results
    end
    
    def extended other
      puts "instance extended by #{other}"  
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
