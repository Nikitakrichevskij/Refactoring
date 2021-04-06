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
    case type
    when Constants::CARD_TYPES[:usual] then current_account.card << CardUsual.new
    when Constants::CARD_TYPES[:capitalist] then current_account.card << CardCapitalist.new
    when Constants::CARD_TYPES[:virtual] then current_account.card << CardVirtual.new
    end
    store.save
  end

  def show_cards
    return communication.view.output(:no_card_exist) if @current_account.card.empty?

    current_account.card.each_with_index do |card, index|
      puts I18n.t(:show_cards, card_number: card.number, card_type: card.type, index: index + 1)
    end
  end

  def destroy_card
    return communication.view.output(:no_card_exist) if @current_account.card.empty?

    communication.view.output do
      current_account.card.each_with_index do |card, index|
        puts I18n.t(:delete_card, card_number: card.number, card_type: card.type, index: index + 1)
      end
    end
    answer = communication.serial_number_of_card(@current_account)
    @current_account.card.delete_at(answer.to_i.pred)
    @store.save
  end

  def put_money
    return communication.view.output(:no_card_exist) if @current_account.card.empty?

    communication.view.output do
      current_account.card.each_with_index do |card, index|
        puts I18n.t(:put_money, card_number: card.number, card_type: card.type, index: index + 1)
      end
    end
    selected_card = communication.serial_number_of_card(@current_account)
    money_amount = communication.money_amount
    return if current_card(selected_card).operation_put_valid?(money_amount) == false

    current_card(selected_card).put_money(money_amount)
    @store.save
  end

  def withdraw_money
    return communication.view.output(:no_card_exist) if @current_account.card.empty?

    communication.view.output do
      current_account.card.each_with_index do |card, index|
        puts I18n.t(:withdraw_money, card_number: card.number, card_type: card.type, index: index + 1)
      end
    end
    selected_card = communication.serial_number_of_card(@current_account)
    money_amount = communication.money_amount
    return if current_card(selected_card).operation_withdraw_valid?(money_amount) == false

    current_card(selected_card).withdraw_money(money_amount)
    @store.save
  end

  def send_money
    return communication.view.output(:no_card_exist) if @current_account.card.empty?

    communication.view.output do
      current_account.card.each_with_index do |card, index|
        puts I18n.t(:send_money, card_number: card.number, card_type: card.type, index: index + 1)
      end
    end
    selected_card = communication.serial_number_of_card(@current_account)
    money_amount = communication.money_amount
    recipient_card = communication.recipient_card_input
    return if current_card(selected_card).operation_send_valid?(money_amount) == false

    current_card(selected_card).send_money(money_amount, another_card(recipient_card))
    @store.save
  end

  private

  def another_card(recipient_card)
    @accounts.map(&:card).flatten.select { |card| card.number == recipient_card }[0]
  end

  def current_card(selected_card)
    @current_account.card[selected_card.pred]
  end
end
