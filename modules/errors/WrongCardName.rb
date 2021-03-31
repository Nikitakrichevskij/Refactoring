class WrongCardName < StandardError
  ERROR_MESSAGE = I18n.t(:wrong_card_name)
  def initialize
    super(ERROR_MESSAGE)
  end
end
