class WrongSerial < StandardError
  ERROR_MESSAGE = I18n.t(:wrong_serial)
  def initialize
    super(ERROR_MESSAGE)
  end
end
