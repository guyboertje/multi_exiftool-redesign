# coding: utf-8
module MultiExiftool

  # Mixin for Reader and Writer.
  module ExecutableBase

    def self.included other
      down_name = other.name.downcase
      other.class_eval "def parse_results; parse_#{down_name}_results; end"
      other.class_eval "def command; #{down_name}_command; end"
    end

    attr_accessor :errors, :numerical
    attr_writer :options, :filenames

    def execute # :nodoc:
      prepare_execution
      execute_command
      parse_results
    end
    
    alias read execute
    alias write execute

    def filenames
      Array(@filenames)
    end

    private
    
    def prepare_execution
      @errors = []
    end

  end

end
