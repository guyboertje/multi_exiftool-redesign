module MultiExiftool
  module InstanceRoleExtender

    def as_daemon(opts = {})
      include_roles(allocate, DAEMON_ROLES).tap do |inst|
        inst.options = opts
      end
    end

    def new(opts = {})
      include_roles(allocate, NORMAL_ROLES).tap do |inst|
        inst.options = opts
      end
    end

    private

    def include_roles instance, roles
      _roles = [roles].flatten
      _roles.each do |r|
        instance.extend r
      end
      instance
    end
  end
end
