# coding: utf-8
require_relative 'executable'
require_relative 'daemon_executable'

require 'json'

module MultiExiftool
  DAEMON_ROLES = [MultiExiftool::DaemonExecutable]
  NORMAL_ROLES = [MultiExiftool::Executable]
  COMMON_ROLES = [MultiExiftool::Options, MultiExiftool::Sanitizing]

  # Handle reading of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # the results as well as possible errors.
  class Reader
    class << self
      def as_daemon
        new DAEMON_ROLES
      end

      def name
        "Reader"
      end
    end

    COMMON_ROLES.each do |role|
      include role
    end

    attr_accessor :exiftool_command, :errors, :numerical, :tags, :group
    attr_writer   :options, :filenames

    def initialize roles=NORMAL_ROLES, opts={}
      @exiftool_command = 'exiftool -j'
      @options = opts
      roles.each do |role|
        self.extend role
      end
    end

    def filenames
      Array(@filenames)
    end
  end
end

