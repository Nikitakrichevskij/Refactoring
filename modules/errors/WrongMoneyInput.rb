class WrongMoneyInput < StandardError
  ERROR_MESSAGE = I18n.t(:incorrect_money_amount)
  def initialize
    super(ERROR_MESSAGE)
  end
end
