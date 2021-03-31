class WrongCardNumber < StandardError
  ERROR_MESSAGE = I18n.t(:wrong_card_number)
  def initialize
    super(ERROR_MESSAGE)
  end
end
