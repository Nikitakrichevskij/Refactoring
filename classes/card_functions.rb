class CardFunctions
  attr_reader :communication, :store, :current_account, :accounts

  def initialize(current_account, store, accounts)
    @communication = Communication.new
    @current_account = current_account
    @store = store
    @accounts = accounts
  end

  def create_card
    type = communication.card_init
    card = CardGenerator.new.cards(type)
    @current_account.card << card
    @store.save
  end

  def show_cards
    return communication.output.no_cards if @current_account.card.empty?

    communication.output.show_cards(current_account)
  end

  def destroy_card
    return communication.output.no_cards if @current_account.card.empty?

    communication.output.delete_card(@current_account)
    answer = communication.serial_number_of_card(@current_account)
    @current_account.card.delete_at(answer.to_i - 1)
    @store.save
  end

  def put_money
    return communication.output.no_cards if @current_account.card.empty?

    communication.output.put_on_card(@current_account)
    operation = 'put money'
    @selected_card = communication.serial_number_of_card(@current_account)
    money_amount = communication.put_money_amount
    return if input_check?(operation, current_card_type, money_amount)

    add_money_to_card(current_card, operation, current_card_type, money_amount)
    @store.save
  end

  def withdraw_money
    return communication.output.no_cards if @current_account.card.empty?

    communication.output.withdraw_money(@current_account)
    operation = 'withdraw'
    @selected_card = communication.serial_number_of_card(@current_account)
    money_amount = communication.put_money_amount
    withdrawing_money(current_card, operation, current_card_type, money_amount)
    @store.save
  end

  def send_money
    return communication.output.no_cards if @current_account.card.empty?

    communication.output.send_money(@current_account)
    operation = 'send money'
    @selected_card = communication.serial_number_of_card(@current_account)
    money_amount = communication.put_money_amount
    recipient_card = communication.recipient_card_input
    return if input_check?(operation, current_card_type, money_amount)

    withdrawing_money(current_card, operation, current_card_type, money_amount)
    sending_money(another_card(recipient_card), money_amount)
  end

  private

  def another_card(recipient_card)
    @accounts.map(&:card).flatten.select { |card| card.number == recipient_card }[0]
  end

  def sending_money(somecard, amount)
    somecard.balance += amount
    @store.save
  end

  def current_card
    @current_account.card[@selected_card - 1]
  end

  def current_card_type
    current_card.type
  end

  def tax_calculate(operation, type, amount)
    Tax.new.withdraw_put_tax(operation, type, amount)
  end

  def input_check?(operation, type, amount)
    tax_calculate(operation, type, amount) > amount.to_i
  end

  def add_money_to_card(somecard, operation, type, amount)
    somecard.balance += amount - tax_calculate(operation, type, amount)
  end

  def withdrawing_money(somecard, operation, type, amount)
    somecard.balance -= amount + tax_calculate(operation, type, amount)
  end
end
