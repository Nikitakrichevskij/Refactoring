class CardVirtual < Card
  attr_accessor :number, :balance, :type

  DEFAULT_BALANCE = 50.00

  TYPE = 'virtual'.freeze

  TAXES = {
    withdraw: 0.88,
    put: 1,
    sender: 1
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