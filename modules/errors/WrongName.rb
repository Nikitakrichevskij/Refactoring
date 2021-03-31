class WrongName < StandardError
  ERROR_MESSAGE = I18n.t(:wrong_name)
  def initialize
    super(ERROR_MESSAGE)
  end
end
