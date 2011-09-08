module DeviseJohnHancockAuthenticatable

  class Logger
    def self.send(message, logger = Rails.logger)
      if logger && ::Devise.john_hancock_logger
        logger.add 0, "\e[36mJOHN_HANCOCK:\e[0m #{message}"
      end
    end
  end

end
