class Communication
  include Validation
  attr_reader :output, :login

  def initialize
    @output = Outputs.new
  end

  def start_menu
    output.welcome
    input = gets.chomp
    validation_start_menu(input)
    input
  rescue WrongCommand
    output.wrong_command
    retry
  end

  def name_init
    output.name
    input = gets.chomp
    name_valid(input)
    input
  rescue WrongName
    retry
  end

  def age_init
    output.age
    input = gets.chomp
    age_valid(input)
    input
  rescue WrongAge
    retry
  end

  def login_init(accounts)
    output.login
    input = gets.chomp
    login_valid(input, accounts)
    input
  rescue WrongLogin
    retry
  end

  def login_search(accounts)
    output.login
    @login = gets.chomp
    login_search_valid?(accounts, login)
    login
  rescue NoAcc
    output.wrong_login
    retry
  end

  def password_search(accounts)
    output.password
    password = gets.chomp
    password_search_valid?(accounts, login, password)
    password
  rescue WrongPassword
    output.wrong_password
    retry
  end

  def password_init
    output.password
    input = gets.chomp
    password_valid(input)
    input
  rescue WrongPassword
    output.wrong_command
    retry
  end

  def card_init
    output.card_init
    input = gets.chomp
    card_valid(input)
    input
  rescue WrongCardName
    output.wrong_command
    retry
  end

  def main_menu
    output.user_actions
    input = gets.chomp
    main_menu_valid(input)
    input
  rescue WrongCommand
    retry
  end

  def delete_card
    gets.chomp
    # delete_card_valid(input, account)
  end

  def serial_number_of_card(current_acc)
    input = gets.chomp
    serial_card_input_valid(input, current_acc)
    input.to_i
  rescue WrongSerial
    retry
  end

  def put_money_amount
    output.money_amount
    gets.chomp.to_i
  end

  def recipient_card_input
    output.recipient_card
    gets.chomp
  end
end
