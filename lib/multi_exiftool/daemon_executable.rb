# coding: utf-8

module MultiExiftool
  # Mixin for Reader and Writer.
  module DaemonExecutable

    def reader_command
      cmd = [reader_exiftool_command]
      cmd << options_args
      cmd << tags_args
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    def writer_command
      cmd = [writer_exiftool_command]
      cmd << options_args
      cmd << values_args
      cmd << escaped_filenames
      cmd.flatten.join(' ')
    end

    def reader_exiftool_command
      'exiftool -j'
    end

    def writer_exiftool_command
      'exiftool'
    end

    private

    def execute_command
      stdin, @stdout, @stderr = Open3.popen3(command)
    end

    def parse_writer_results
      @errors = @stderr.readlines
      @errors.empty?
    end

    def parse_reader_results
      stdout = @stdout.read
      @errors = @stderr.readlines
      json = JSON.parse(stdout)
      json.map {|values| Values.parsed(values)}
    rescue JSON::ParserError
      return []
    end

  end

end
