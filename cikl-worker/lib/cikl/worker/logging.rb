require 'logger'
module Cikl
  module Worker
    @@logger = nil
    def self.logger
      @@logger
    end
    def self.logger=(new_logger)
      @@logger = new_logger
    end
    lambda do
      _logger = ::Logger.new(STDERR)
      _logger.level = ::Logger::INFO
      #_logger.level = ::Logger::DEBUG
      Cikl::Worker.logger = _logger
    end.call()

    module Logging
      def error(msg)
        Cikl::Worker.logger.error(msg) if Cikl::Worker.logger
      end
      def warn(msg)
        Cikl::Worker.logger.warn(msg) if Cikl::Worker.logger
      end
      def info(msg)
        Cikl::Worker.logger.info(msg) if Cikl::Worker.logger
      end
      def debug(msg)
        Cikl::Worker.logger.debug(msg) if Cikl::Worker.logger
      end
    end
  end
end

