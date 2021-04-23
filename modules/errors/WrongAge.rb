class WrongAge < StandardError
  def initialize
    super(I18n.t(:wrong_age))
  end
end
