# frozen_string_literal: true

class CardCapitalist < Card
  attr_accessor :number, :balance, :type

  DEFAULT_BALANCE = 100.00

  TYPE = 'capitalist'

  TAXES = {
    withdraw: 0.04,
    put: 10,
    sender: 0.1
  }.freeze

  def initialize
    @type = TYPE
    @balance = DEFAULT_BALANCE
    super()
  end

  def withdraw_tax(amount)
    TAXES[:withdraw] * amount
  end

  def put_tax(_amount)
    TAXES[:put]
  end

  def send_tax(amount)
    TAXES[:send] * amount
  end
end
