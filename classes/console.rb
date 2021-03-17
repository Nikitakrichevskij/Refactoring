class Console
  attr_reader :communication

  def initialize
    @communication = Communication.new
  end

  def start
    input = communication.start_menu
    case input
    when 'create' then create
    when 'load' then loading
    when 'exit' then exit_command
    end
  end

  def main_menu
    case communication.main_menu
    when 'SC' then functions.show_cards
    when 'CC' then functions.create_card
    when 'DC' then functions.destroy_card
    when 'PM' then functions.put_money
    when 'WM' then functions.withdraw_money
    when 'SM' then functions.send_money
    when 'DA' then functions.destroy_account
    when 'exit' then exit_command
    end
  end

  def exit_command
    exit
  end
end
