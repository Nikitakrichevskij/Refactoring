class Outputs
  def initialize
    I18n.load_path << Dir["#{File.expand_path('config/locales')}/*.yml"]
    I18n.default_locale = :en
  end

  def welcome
    puts I18n.t :welcome
  end

  def wrong_command
    puts I18n.t(:wrongCommand, commands: Constants::START_MENU_COMMANDS)
  end

  def name
    puts I18n.t(:name)
  end

  def age
    puts I18n.t(:age)
  end

  def login
    puts I18n.t(:login)
  end

  def password
    puts I18n.t(:password)
  end

  def card_init
    puts I18n.t(:card_init)
  end

  def user_actions
    puts I18n.t(:user_actions)
  end

  def delete_card(account)
    account.card.each_with_index do |card, index|
      puts I18n.t(:delete_card, card_number: card.number, card_type: card.type, index: index + 1)
    end
  end

  def put_on_card(account)
    account.card.each_with_index do |card, index|
      puts I18n.t(:put_money, card_number: card.number, card_type: card.type, index: index + 1)
    end
  end

  def withdraw_money(account)
    account.card.each_with_index do |card, index|
      puts I18n.t(:withdraw_money, card_number: card.number, card_type: card.type, index: index + 1)
    end
  end

  def send_money(account)
    account.card.each_with_index do |card, index|
      puts I18n.t(:send_money, card_number: card.number, card_type: card.type, index: index + 1)
    end
  end

  def put_money(account)
    account.card.each_with_index do |card, index|
      puts I18n.t(:put_money, card_number: card.number, card_type: card.type, index: index + 1)
    end
  end

  def show_cards(account)
    account.card.each do |card|
      puts I18n.t(:show_cards, card_number: card.number, card_type: card.type)
    end
  end

  def put_error
    puts I18n.t(:put_error)
  end

  def money_amount
    puts I18n.t(:money_amount)
  end

  def recipient_card
    puts I18n.t(:recipient_card)
  end

  def no_cards
    puts I18n.t(:no_card_exist)
  end

  def wrong_password
    puts I18n.t(:wrong_password)
  end

  def wrong_login
    puts I18n.t(:wrong_login)
  end
end
