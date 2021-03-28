class CardUsual < Card
  attr_accessor :number, :balance, :type

  DEFAULT_BALANCE = 50.00

  TYPE = 'usual'.freeze

  TAXES = {
    withdraw: 0.05,
    put: 0.02,
    send: 20
  }.freeze

  def initialize
    @type = TYPE
    @balance = DEFAULT_BALANCE
    super()
  end

  def withdraw_tax(amount)
    TAXES[withdraw] * amount
  end

  def put_tax(amount)
    TAXES[put] * amount
  end

  def send_tax(amount)
    TAXES[send] * amount
  end
end