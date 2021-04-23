class WrongMoneyInput < StandardError
  def initialize
    super(I18n.t(:incorrect_money_amount))
  end
end
