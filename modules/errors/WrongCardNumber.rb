class WrongCardNumber < StandardError
  def initialize
    super(I18n.t(:wrong_card_number))
  end
end
