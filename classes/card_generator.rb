class Card
  attr_reader :type, :number
  attr_accessor :balance

  def initialize
    @number = number_generate
  end

  def number_generate
    Constans::CARD_NUMBER_AMOUNT.times.map { rand(Constans::CARD_NUMBER_RANGE) }.join
  end

  def put_money(amount)
    @balance += amount - put_tax(amount)
  end

  def operation_put_valid?(amount)
    amount >= put_tax(amount)
  end

  def withdraw_money(amount)
    amount - withdraw_tax(amount)
  end

  def operation_withdraw_valid?(amount)
    (@balance - amount - withdraw_tax(amount)).positive?
  end

  def send_money(amount)
    @balance -= amount - sender_tax(amount)
  end

  def operation_send_valid?(amount)
    (@balance - amount - send_tax(amount)).positive?
  end

  private

  def withdraw_tax(amount)
    raise NotImplementedError
  end

  def put_tax(amount)
    raise NotImplementedError
  end

  def send_tax(amount)
    raise NotImplementedError
  end
end
