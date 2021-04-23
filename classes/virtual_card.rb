# frozen_string_literal: true

class CardVirtual < Card
  attr_accessor :number, :balance, :type

  DEFAULT_BALANCE = 150.00

  TYPE = 'virtual'

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
    TAXES[:withdraw] * amount
  end

  def put_tax(_amount)
    TAXES[:put]
  end

  def send_tax(_amount)
    TAXES[:send]
  end
end
