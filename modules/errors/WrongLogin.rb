class WrongLogin < StandardError
  ERROR_MESSAGE = I18n.t(:wrong_login)
  def initialize
    super(ERROR_MESSAGE)
  end
end
