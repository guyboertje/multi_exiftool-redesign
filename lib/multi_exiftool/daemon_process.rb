require 'singleton'

IO4 = if IO.respond_to?(:popen4)
  IO
else
  require 'open4'
  Open4
end

module MultiExiftool

  DaemonProcessClosed = Class.new(RuntimeError)

  class DaemonProcess

    include Singleton

    attr_reader :errors, :last_result

    def self.open
      inst = instance
      inst.open
    end

    def self.execute command
      open.execute command
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
      self
    end

    def read
      raise DaemonProcessClosed.new("Process is not read ready") unless ready_to_read? 
      output = raw_read
      read_errors
      @last_result = output.gsub "{ready}\n",""
      @state = set_state 1
      if @last_result.empty?
        read_errors
      end
      @last_result
    end

    def open
      return self if open?
      command = ["exiftool -stay_open True -@ -"]
      open_process string_from command
      @state = set_state 1
      sleep 0.1
      self
    end

    def close
      unless @in_pipe.closed?
        close_process
        @in_pipe.close
      end
      @out_pipe.close unless @out_pipe.closed?
      @err_pipe.close unless @err_pipe.closed?
      @state = 0
      self
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
    
    def open_process command
       @pid, @in_pipe, @out_pipe, @err_pipe = IO4.popen4(command)
    end

    def set_state new_state
      @state = @in_pipe.closed? ? 0 : new_state
    end
    
    def read_errors
      # unfortunately, can't reliably read
      # without blocking on @err_pipe
      # under 1.9 and jruby 1.6.6
      # presume that if in_pipe is closed
      # then the process ended with an error
      if @in_pipe.closed?
        @errors = [@err_pipe.readline.chomp] rescue []
        unless @errors.empty?
          @errors << @err_pipe.readlines(10.chr)
        end
      end
    end

    def raw_read
      raise DaemonProcessClosed.new("Process is inactive") if @out_pipe.closed?
      stop, output = 0, ''
      until stop > 5
        out = nil
        begin
          out = @out_pipe.gets(10.chr)
          break if out =~ /{ready}/
          output << out
        rescue => e
          puts "raw read exception"
          puts e.inspect
        end
        if out.nil?
          stop += 1
          sleep 0.1
        end
      end
      output
    end

    def raw_write command_array
      raise DaemonProcessClosed.new("Process is not active") if @in_pipe.closed?
      @in_pipe.puts string_from command_array
      @in_pipe.flush
    end

    def string_from array
      array.join(10.chr) + 10.chr
    end

    def close_process
      raw_write %w(-stay_open False)
    end
  end
end
