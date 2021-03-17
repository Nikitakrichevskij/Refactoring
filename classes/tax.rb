class Tax
  include Constants
  def withdraw_put_tax(operation, type, amount)
    return put_tax(type, amount) if operation == 'put money'
    return withdraw_tax(type, amount) if operation == 'withdraw'
    return send_money(type, amount) if operation == 'send money'
  end

  private

  def put_tax(type, amount)
    return Constants::PUT_TAX[type.to_sym] * amount if type == 'usual'

    Constants::PUT_TAX[type.to_sym]
  end

  def withdraw_tax(type, amount)
    amount * Constants::WITHDRAW_TAX[type.to_sym]
  end

  def send_money(type, amount)
    return Constants::SEND_TAX[type.to_sym] if type == 'usual'
    return Constants::SEND_TAX[type.to_sym] if type == 'virtual'

    Constants::SEND_TAX[type.to_sym] * amount
  end
end
