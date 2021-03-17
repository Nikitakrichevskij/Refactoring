module Validation
  include Errors
  def validation_start_menu(input)
    raise WrongCommand unless Constants::START_MENU_COMMANDS.include?(input)
  end

  def name_valid(input)
    raise WrongName unless input != '' && input[0].upcase == input[0]
  end

  def login_valid(input, accounts)
    raise WrongLogin unless input.length > 4 && input.length < 20 && login_exist?(accounts, input)
  end

  def login_exist?(accounts, login)
    accounts.select { |k, _v| k.login == login }.none?
  end

  def login_search_valid?(accounts, login)
    raise NoAcc if login_exist?(accounts, login)
  end

  def password_search_valid?(accounts, login, password)
    raise WrongPassword unless password_exist?(accounts, login, password)
  end

  def password_exist?(accounts, login, password)
    accounts.select { |k, _v| k.login == login }[0].password.eql?(password)
  end

  def age_valid(input)
    raise WrongAge unless input.to_i >= 23 && input.to_i <= 90
  end

  def password_valid(input)
    raise WrongPassword unless input.length > 6 && input.length < 30
  end

  def card_valid(input)
    raise WrongCardName unless Constants::CARDS_TYPE.include?(input)
  end

  def main_menu_valid(input)
    raise WrongCommand unless Constants::MAIN_MENU_COMMANDS.include?(input)
  end

  def serial_card_input_valid(input, current_acc)
    raise WrongSerial unless current_acc.card.size >= input.to_i
  end
end
