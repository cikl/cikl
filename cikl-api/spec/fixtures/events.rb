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
      domain,
      "sub1.#{domain}",
      "sub2.#{domain}",
      "deep.sub1.#{domain}",
      "deep.sub2.#{domain}"
    ]
  end

  def self._fqdn_tests
    ret = []
    _fqdn_tests_names('fqdn.fqdn_tests.com').each do |fqdn|
      event = Fabricate(:event, source: 'fqdn_tests')
      event.observables.dns_answer << Fabricate(:dns_answer_a, name: name)
      ret << event
    end

    _fqdn_tests_names('dns_name.fqdn_tests.com').each do |fqdn|
      event = Fabricate(:event, source: 'fqdn_tests')
      event.observables.dns_answer << Fabricate(:dns_answer_ns, name: fqdn)
      ret << event
    end

    _fqdn_tests_names('dns_fqdn.fqdn_tests.com').each do |fqdn|
      event = Fabricate(:event, source: 'fqdn_tests')
      event.observables.dns_answer << Fabricate(:dns_answer_ns, fqdn: "ns1.#{fqdn}")
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
