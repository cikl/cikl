require 'cikl/worker/base/config'
module Cikl
  module Worker
    module DNS
      module Config
        MYPATH = Pathname.new(__FILE__).dirname.expand_path
        DEFAULT_CONF = MYPATH + "unbound.conf"
        ROOT_HINTS = MYPATH + "named.root"

        def self.create_config(app_root)
          config = Cikl::Worker::Base::Config.create_config(app_root)

          config.define "dns.unbound_config_file", 
            :type => :filename,
            :description => "Path to the default unbound configuration file",
            :default => app_root.join('config/unbound.conf').to_s,
            :required => true

          config.define "dns.root_hints_file", 
            :type => :filename,
            :description => "Path to root.hints file",
            :default => app_root.join('config/named.root').to_s,
            :required => true
        end
      end
    end
  end
end
