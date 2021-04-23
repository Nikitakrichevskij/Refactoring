# frozen_string_literal: true

class WrongAge < StandardError
  def initialize
    super(I18n.t(:wrong_age))
  end
end
