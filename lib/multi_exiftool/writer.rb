# coding: utf-8
require_relative 'executable'

module MultiExiftool

  # Handle writing of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # possible errors.
  class Writer
    class << self
      include InstanceRoleExtender

      def name
        "Writer"
      end
    end

    COMMON_ROLES.each do |role|
      include role
    end

    attr_accessor :overwrite_original
    attr_writer   :values

    def values
      Array(@values)
    end

  end

end
