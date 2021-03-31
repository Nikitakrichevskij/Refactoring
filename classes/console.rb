class Console
  attr_reader :communication

  def initialize
    @communication = Communication.new
  end

  def start
    input = communication.start_menu
    case input
    when  Constants::COMMANDS[:create_account] then create
    when  Constants::COMMANDS[:load_account] then loading
    when  Constants::COMMANDS[:exit] then exit_command
    end
  end

  def main_menu
    case communication.main_menu
    when Constants::COMMANDS[:show_cards] then functions.show_cards
    when Constants::COMMANDS[:card_create] then functions.create_card
    when Constants::COMMANDS[:card_destroy] then functions.destroy_card
    when Constants::COMMANDS[:put_money] then functions.put_money
    when Constants::COMMANDS[:withdraw_money] then functions.withdraw_money
    when Constants::COMMANDS[:send_money] then functions.send_money
    when Constants::COMMANDS[:delete_account] then functions.destroy_account
    when Constants::COMMANDS[:exit] then exit_command
    end
  end

  def exit_command
    exit
  end
end
