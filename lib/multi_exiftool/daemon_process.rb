require 'open3'
require 'singleton'

module MultiExiftool

  DaemonProcessClosed = Class.new(RuntimeError)

  class DaemonProcess

    include Singleton

    attr_reader :errors, :last_result

    def self.open
      inst = instance
      inst.open
    end

    def execute command
      write(command).read
    end

    def write command
      raise DaemonProcessClosed.new("Process is not write ready") unless open? 
      @errors, @last_result = '',''
      raw_write [command].flatten
      raw_write ["-execute"]
      @state = set_state 2
      read_errors
      sleep 0.2
      self
    end

    def read
      raise DaemonProcessClosed.new("Process is not read ready") unless ready_to_read? 
      output = raw_read
      read_errors
      @last_result = output.gsub("{ready}\n","")
      @state = set_state 1
      @last_result
    end

    def open
      return if open?
      args = ["exiftool -stay_open True -@ -"]
      actually_open build_string(args)
      read_errors
      @state = set_state 1
      sleep 0.1
      self
    end

    def close
      unless @in_pipe.closed?
        normal_close() unless @in_pipe.closed?
        @in_pipe.close
      end
      @out_pipe.close unless @out_pipe.closed?
      @err_pipe.close unless @err_pipe.closed?
      @state = 0
    end

    def errors?
      !@errors.empty?
    end

    def closed?
      @state == 0
    end

    def ready_to_read?
      @state == 2
    end

    def open?
      @state == 1
    end

    alias :ready_to_write? :open?

    private
    
    def actually_open command
       @in_pipe, @out_pipe, @err_pipe = Open3.popen3(command)
       ap @out_pipe.methods
    end

    def set_state new_state
      @state = @in_pipe.closed? ? 0 : new_state
    end
    
    def read_errors
      @errors = @err_pipe.read_nonblock(8192) rescue ""
    end

    def raw_read
      raise DaemonProcessClosed.new("Process is inactive") if @out_pipe.closed?
      stop, out = 0, ''





      
      until stop > 9 || out =~ /{ready}/
        begin
          out << @out_pipe.read_nonblock(8192)
          apr out, "raw_read: out"
        rescue IO::WaitReadable
          sleep 0.1
        end
        stop += 1
      end
      out
    end

    def raw_write command_array
      raise DaemonProcessClosed.new("Process is not active") if @in_pipe.closed?
      tow = build_string(command_array)
      @in_pipe.puts tow
      @in_pipe.flush
    end

    def build_string collection
      collection.join(10.chr) + 10.chr
    end

    def normal_close
      raw_write %w(-stay_open False)
    end
  end
end
