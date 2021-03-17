module Errors
  class WrongCommand < StandardError
    ERROR_MESSAGE = "Comands must be #{Constants::START_MENU_COMMANDS}".freeze

    def initialize
      super(ERROR_MESSAGE)
    end
  end

  class WrongName < StandardError
    ERROR_MESSAGE = 'Your name must not be empty and starts with first upcase letter'.freeze
    def initialize
      super(ERROR_MESSAGE)
    end
  end

  class WrongAge < StandardError
    ERROR_MESSAGE = 'Your Age must be greeter then 23 and lower then 90'.freeze
    def initialize
      super(ERROR_MESSAGE)
    end
  end

  class WrongLogin < StandardError
    ERROR_MESSAGE = 'Login must be longer then 4 symbols. Login must be shorter then 20 symbols'.freeze
    def initialize
      super(ERROR_MESSAGE)
    end
  end

  class WrongPassword < StandardError
    ERROR_MESSAGE = 'Password must be longer then 6 symbols. Password must be shorter then 30 symbols'.freeze
    def initialize
      super(ERROR_MESSAGE)
    end
  end

  class NoAcc < StandardError
    ERROR_MESSAGE = 'Cant find account with this login'.freeze
    def initialize
      super(ERROR_MESSAGE)
    end
  end

  class WrongCardName < StandardError
    ERROR_MESSAGE = 'Worng type of card'.freeze
    def initialize
      super(ERROR_MESSAGE)
    end
  end

  class WrongCardNumber < StandardError
    ERROR_MESSAGE = 'Wrong number of card'.freeze
    def initialize
      super(ERROR_MESSAGE)
    end
  end

  class WrongSerial < StandardError
    ERROR_MESSAGE = 'Wrong serial number of card'.freeze
    def initialize
      super(ERROR_MESSAGE)
    end
  end
end
