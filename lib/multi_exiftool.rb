# coding: utf-8
require_relative 'multi_exiftool/values'
require_relative 'multi_exiftool/options'
require_relative 'multi_exiftool/sanitizing'
require_relative 'multi_exiftool/instance_role_extender'
require_relative 'multi_exiftool/executable_base'
require_relative 'multi_exiftool/executable'
require_relative 'multi_exiftool/daemon_process'
require_relative 'multi_exiftool/daemon_executable'

module MultiExiftool

  OperationsError = Class.new(StandardError)

  DAEMON_ROLES = [MultiExiftool::DaemonExecutable]
  NORMAL_ROLES = [MultiExiftool::Executable]
  COMMON_ROLES = [MultiExiftool::ExecutableBase, MultiExiftool::Options, MultiExiftool::Sanitizing]

end

require_relative 'multi_exiftool/reader'
require_relative 'multi_exiftool/writer'
