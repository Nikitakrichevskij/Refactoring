module Constants
  START_MENU_COMMANDS = %w[create load exit].freeze
  CARDS_TYPE = %w[usual capitalist virtual].freeze
  MAIN_MENU_COMMANDS = %w[SC CC DC PM WM SM DA exit].freeze
  WITHDRAW_TAX = {
    usual: 0.05,
    capitalist: 0.04,
    virtual: 0.88
  }.freeze

  PUT_TAX = {
    usual: 0.02,
    capitalist: 10,
    virtual: 1
  }.freeze

  SEND_TAX = {
    usual: 20,
    capitalist: 0.1,
    virtual: 1
  }.freeze
end
