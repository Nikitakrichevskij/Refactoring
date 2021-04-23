# frozen_string_literal: true

class Communication
  include Validation
  attr_reader :view, :login

  def initialize
    @view = Outputs.new
  end

  def start_menu
    view.output(:welcome)
    input = gets.chomp
    validation_start_menu(input)
    input
  rescue WrongCommand
    view.output(:wrong_command)
    retry
  end

  def name_init
    view.output(:name)
    input = gets.chomp
    name_valid(input)
    input
  rescue WrongName
    view.output(:wrong_name)
    retry
  end

  def age_init
    view.output(:age)
    input = gets.chomp
    age_valid(input)
    input
  rescue WrongAge
    view.output(:wrong_age)
    retry
  end

  def login_init(accounts)
    view.output(:login)
    input = gets.chomp
    login_valid(input, accounts)
    input
  rescue WrongLogin
    view.output(:wrong_login)
    retry
  end

  def login_search(accounts)
    view.output(:login)
    @login = gets.chomp
    login_search_valid?(accounts, login)
    login
  rescue NoAccount
    view.output(:no_account)
    retry
  end

  def password_search(accounts)
    view.output(:password)
    password = gets.chomp
    password_search_valid?(accounts, login, password)
    password
  rescue WrongPassword
    view.output(:wrong_password)
    retry
  end

  def password_init
    view.output(:password)
    input = gets.chomp
    password_valid(input)
    input
  rescue WrongPassword
    view.output(:wrong_password)
    retry
  end

  def card_init
    view.output(:card_init)
    input = gets.chomp
    card_valid(input)
    input
  rescue WrongCardName
    view.output(:wrong_card_name)
    retry
  end

  def main_menu
    view.output(:user_actions)
    input = gets.chomp
    main_menu_valid(input)
    input
  rescue WrongCommand
    view.output(:wrong_command)
    retry
  end

  def serial_number_of_card(current_acc)
    input = gets.chomp
    serial_card_input_valid(input, current_acc)
    input
  rescue WrongSerial
    view.output(:wrong_serial)
    retry
  end

  def card_delete_confirmation(current_account)
    view.output do
      current_account.card.each do |card|
        puts I18n.t(:card_delete_confirmation, card_number: card.number)
      end
    end
    gets.chomp
  end

  def money_amount(output)
    view.output(output)
    input = gets.chomp.to_i
    money_amount_valid(input)
    input.to_i
  rescue WrongMoneyInput
    view.output(:incorrect_money_amount)
    retry
  end

  def recipient_card_input
    view.output(:recipient_card)
    gets.chomp
  end
end
