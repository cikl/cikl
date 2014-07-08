require 'ipaddr'
module Fixtures
  def self.events
    @events ||= _build_events()
  end

  private

  def self._build_events
    ret = []
    ret.concat(_fqdn_tests)
    ret.concat(_ipv4_tests)
    ret
  end

  def self._fqdn_tests_names(domain)
    [
      "sub.#{domain}",
      "deep1.sub.#{domain}",
      "deep2.sub.#{domain}",
      "really.really.really.deep.sub.#{domain}"
    ]
  end

  def self._fqdn_tests
    ret = []
    _fqdn_tests_names('fqdn.fqdn-tests.com').each do |fqdn|
      event = Fabricate(:event, source: 'fqdn_tests')
      event.observables.fqdn << Fabricate(:fqdn, fqdn: fqdn)
      ret << event
    end

    _fqdn_tests_names('dns-name.fqdn-tests.com').each do |fqdn|
      event = Fabricate(:event, source: 'fqdn_tests')
      event.observables.dns_answer << Fabricate(:dns_answer_ns, name: fqdn)
      ret << event
    end

    _fqdn_tests_names('dns-fqdn.fqdn-tests.com').each do |fqdn|
      event = Fabricate(:event, source: 'fqdn_tests')
      event.observables.dns_answer << Fabricate(:dns_answer_ns, fqdn: fqdn)
      ret << event
    end

    ret
  end

  def self._ipv4_tests
    ret = []

    IPAddr.new("100.1.1.0/24").to_range.each do |ipv4_only_ip|
      event = Fabricate(:event, source: 'ipv4_tests')
      event.observables.ipv4 << Fabricate(:ipv4, ipv4: ipv4_only_ip)
      ret << event
    end

    IPAddr.new("100.1.2.0/24").to_range.each do |shared_ip|
      event = Fabricate(:event, source: 'ipv4_tests')
      event.observables.ipv4 << Fabricate(:ipv4, ipv4: shared_ip)
      ret << event

      event = Fabricate(:event, source: 'ipv4_tests')
      event.observables.dns_answer << Fabricate(:dns_answer_a, ipv4: shared_ip)
      ret << event
    end

    IPAddr.new("100.1.3.0/24").to_range.each do |dns_ipv4_only_ip|
      event = Fabricate(:event, source: 'ipv4_tests')
      event.observables.dns_answer << Fabricate(:dns_answer_a, ipv4: dns_ipv4_only_ip)
      ret << event
    end

    ret
  end

end
