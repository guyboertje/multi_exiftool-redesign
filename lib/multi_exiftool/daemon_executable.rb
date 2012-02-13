# coding: utf-8

module MultiExiftool
  # Mixin for Reader and Writer.
  module DaemonExecutable

    def included other
      puts "instance included"
    end

    def reader_command
      cmd = reader_exiftool_command
      cmd << options_args
      cmd << tags_args
      cmd << escaped_filenames
      cmd.flatten.join(10.chr)
    end

    def writer_command
      cmd = writer_exiftool_command
      cmd << options_args
      cmd << values_args
      cmd << escaped_filenames
      cmd.flatten.join(10.chr)
    end

    def reader_exiftool_command
      ["-j"]
    end

    def writer_exiftool_command
      []
    end

    private

    def execute_command
      unless @daemon
        @daemon = MultiExiftool::DaemonProcess.open
      end
      @daemon.write command
    end

    def parse_writer_results
      @errors = @daemon.errors
      @errors.empty?
    end

    def parse_reader_results
      stdout = @daemon.read
      @errors = @daemon.errors
      json = JSON.parse(stdout)
      json.map {|values| Values.parsed(values)}
    rescue JSON::ParserError
      return []
    end

  end

end
