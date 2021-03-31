module Validation
  def validation_start_menu(input)
    raise WrongCommand unless Constants::START_MENU_COMMANDS.include?(input)
  end

  def name_valid(input)
    raise WrongName if input.empty? || input.capitalize != input
  end

  def login_valid(input, accounts)
    raise WrongLogin if input.length < Constants::MIN_LOGIN_LENGTH || input.length > Constants::MAX_LOGIN_LENGTH || login_exist?(
      accounts, input
    )
  end

  def login_exist?(accounts, login)
    accounts.select { |account| account.login == login }.any?
  end

  def login_search_valid?(accounts, login)
    raise NoAcc unless login_exist?(accounts, login)
  end

  def password_search_valid?(accounts, login, password)
    raise WrongPassword unless password_exist?(accounts, login, password)
  end

  def password_exist?(accounts, login, password)
    accounts.select { |account| account.login == login }.first.password.eql?(password)
  end

  def age_valid(input)
    raise WrongAge if input.to_i <= Constants::AGE_MIN || input.to_i >= Constants::AGE_MAX
  end

  def password_valid(input)
    raise WrongPassword if input.length < MIN_PASSWORD_LENGTH || input.length > MAX_PASSWORD_LENGTH
  end

  def card_valid(input)
    raise WrongCardName unless Constants::CARDS_TYPE.include?(input)
  end

  def main_menu_valid(input)
    raise WrongCommand unless Constants::MAIN_MENU_COMMANDS.include?(input)
  end

  def serial_card_input_valid(input, current_acc)
    raise WrongSerial if current_acc.card.size <= input.to_i
  end
end
