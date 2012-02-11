# coding: utf-8
require 'json'

module MultiExiftool
  # Handle reading of metadata via exiftool.
  # Composing the command for the command-line executing it and parsing
  # the results as well as possible errors.
  class Reader
    class << self
      include InstanceRoleExtender

      def name
        "Reader"
      end
    end

    COMMON_ROLES.each do |role|
      include role
    end

    attr_accessor :tags, :group

  end
end

