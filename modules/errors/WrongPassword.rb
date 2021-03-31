class WrongPassword < StandardError
  ERROR_MESSAGE = I18n.t(:wrong_password)
  def initialize
    super(ERROR_MESSAGE)
  end
end
