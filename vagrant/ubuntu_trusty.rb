# Why are you looking, here? 
# Alright, fine. This is a dirty hack to configure multiple network interfaces
# with DHCP on Ubuntu Trusty. Vagrant (1.5.4) does it all wrong: poking around
# with routes, spawning additional dhclient all over the place because yolo.
#
# The real answer is setting the metric on the interfaces so that we can safely
# allow multiple interfaces to use DHCP without creating conflicting default
# routes.

require 'vagrant'
require 'tempfile'
require "vagrant/util/template_renderer"
require Vagrant.source_root.join("plugins/guests/ubuntu/guest")
require Vagrant.source_root.join("plugins/guests/debian/cap/change_host_name")
require Vagrant.source_root.join("plugins/guests/ubuntu/cap/change_host_name")


module VagrantPlugins
  module GuestUbuntuTrusty
    class Guest < VagrantPlugins::GuestUbuntu::Guest
      def detect?(machine)
        machine.communicate.test("cat /etc/issue | grep 'Ubuntu 14.04'")
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "Ubuntu Trusty Guest"
      description "Ubuntu Trusty support."

      guest("ubuntu_trusty", "ubuntu") do
        Guest
      end

      guest_capability("ubuntu_trusty", "configure_networks") do
        Cap::ConfigureNetworks
      end

#      guest_capability("ubuntu_trusty", "change_host_name") do
#        pp [:science!]
#        Cap::ChangeHostName
#      end
    end

    module Cap
#      class ChangeHostName < VagrantPlugins::GuestUbuntu::Cap::ChangeHostName
#      end
      class ConfigureNetworks
        include Vagrant::Util

DHCP_TEMPLATE = <<EOS
auto eth<%= options[:interface] %>
iface eth<%= options[:interface] %> inet dhcp
<% if !options[:use_dhcp_assigned_default_route] %>
  metric 100
<% else %>
  metric 50
<% end %>
EOS

STATIC_TEMPLATE = <<EOS
auto eth<%= options[:interface] %>
iface eth<%= options[:interface] %> inet static
      address <%= options[:ip] %>
      netmask <%= options[:netmask] %>
EOS

        def self.setup_interface(comm, network)
          template = case network[:type].to_sym
                     when :dhcp
                       DHCP_TEMPLATE
                     when :static
                       STATIC_TEMPLATE
                     else
                       raise "Unknown type: #{network[:type]}"
                     end

          content = TemplateRenderer.render_string(template,
                                                   :options => network)
          temp = Tempfile.new("vagrant")
          temp.binmode
          temp.write(content)
          temp.close
          comm.upload(temp.path, "/tmp/vagrant-network-entry")
          eth = "eth#{network[:interface]}"
          comm.sudo("/sbin/ifdown #{eth} && cat /tmp/vagrant-network-entry > /etc/network/interfaces.d/#{eth}.cfg && /sbin/ifup #{eth}")
          comm.sudo("rm /tmp/vagrant-network-entry")
        end

        def self.configure_networks(machine, networks)
          machine.communicate.tap do |comm|
            comm.sudo("echo 'options single-request-reopen' > /etc/resolvconf/resolv.conf.d/tail")
            setup_interface(comm, :interface => 0, :type => :dhcp)
            networks.each do |network|
              setup_interface(comm, network)
            end
            comm.sudo("/sbin/resolvconf -u")
          end
        end
      end
    end
  end
end
