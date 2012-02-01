# coding: utf-8
require_relative 'executable'
require_relative 'execute_as_daemon'

require 'json'

module MultiExiftool
  DAEMON_ROLES = [ExecuteAsDaemon]
  NORMAL_ROLES = [Execute]
  COMMON_ROLES = [Options, Sanitizing]

  # Handle reading of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # the results as well as possible errors.
  class Reader
    class << self
      def as_daemon
        new DAEMON_ROLES
      end
    end

    COMMON_ROLES.each do |role|
      include role
    end

    attr_accessor :exiftool_command, :errors, :numerical, :tags, :group
    attr_writer :options, :filenames

    def initialize roles=[Execute], opts={}
      @exiftool_command = 'exiftool'
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

