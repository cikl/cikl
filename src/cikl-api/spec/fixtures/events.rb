require 'ipaddr'
module Fixtures
  def self.events
    @events ||= _build_events()
  end

  def self.event_count
    self.events.count
  end

  def self.now
    @now ||= DateTime.now
  end

  private

  def self._build_events
    ret = []
    ret.concat(_fqdn_tests)
    ret.concat(_ipv4_tests)
    ret.concat(_import_time_tests)
    ret.concat(_detect_time_tests)
    ret.concat(_source_tests)
    ret.concat(_feed_provider_tests)
    ret.concat(_feed_name_tests)
    ret
  end

  def self._import_time_tests
    ret = []
    [60,31,30,29,7, 1,0].each do |days_ago|
      event = Fabricate(:event, source: 'import_time_tests',
                        import_time: self.now - days_ago)
      event.observables.fqdn << Fabricate(:fqdn, fqdn: "#{days_ago}.import-time-tests.com")
      ret << event
    end

    ret
  end
  

  def self._source_tests
    gen_event = lambda do |i,j|
      event = Fabricate(:event, source: "source_test_#{i}")
      event.observables.fqdn << Fabricate(:fqdn, fqdn: "#{i}-#{j}.source-tests.com")
      event
    end
    ret = []

    25.downto(21) { |i| 5.times { |j| ret << gen_event.call(i,j) } }
    20.downto(16) { |i| 4.times { |j| ret << gen_event.call(i,j) } }
    15.downto(11) { |i| 3.times { |j| ret << gen_event.call(i,j) } }
    10.downto(6) { |i| 2.times { |j| ret << gen_event.call(i,j) } }
    5.downto(1) { |i| 1.times { |j| ret << gen_event.call(i,j) } }

    ret
  end

  def self._feed_provider_tests
    gen_event = lambda do |i,j|
      event = Fabricate(:event, feed_provider: "feed_provider_test_#{i}")
      event.observables.fqdn << Fabricate(:fqdn, fqdn: "#{i}-#{j}.feed-provider-tests.com")
      event
    end
    ret = []

    25.downto(21) { |i| 5.times { |j| ret << gen_event.call(i,j) } }
    20.downto(16) { |i| 4.times { |j| ret << gen_event.call(i,j) } }
    15.downto(11) { |i| 3.times { |j| ret << gen_event.call(i,j) } }
    10.downto(6) { |i| 2.times { |j| ret << gen_event.call(i,j) } }
    5.downto(1) { |i| 1.times { |j| ret << gen_event.call(i,j) } }

    ret
  end

  def self._feed_name_tests
    gen_event = lambda do |i,j|
      event = Fabricate(:event, feed_name: "feed_name_test_#{i}")
      event.observables.fqdn << Fabricate(:fqdn, fqdn: "#{i}-#{j}.feed-name-tests.com")
      event
    end
    ret = []

    25.downto(21) { |i| 5.times { |j| ret << gen_event.call(i,j) } }
    20.downto(16) { |i| 4.times { |j| ret << gen_event.call(i,j) } }
    15.downto(11) { |i| 3.times { |j| ret << gen_event.call(i,j) } }
    10.downto(6) { |i| 2.times { |j| ret << gen_event.call(i,j) } }
    5.downto(1) { |i| 1.times { |j| ret << gen_event.call(i,j) } }

    ret
  end


  def self._detect_time_tests
    ret = []
    [60,31,30,29,7, 1,0].each do |days_ago|
      event = Fabricate(:event, source: 'detect_time_tests',
                        detect_time: self.now - days_ago)
      event.observables.fqdn << Fabricate(:fqdn, fqdn: "#{days_ago}.detect-time-tests.com")
      ret << event
    end
    event = Fabricate(:event, source: 'detect_time_tests')
    event.observables.fqdn << Fabricate(:fqdn, fqdn: "nil.detect-time-tests.com")
    ret << event

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
