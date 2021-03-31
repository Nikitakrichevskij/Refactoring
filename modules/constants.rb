module Constants
  START_MENU_COMMANDS = %w[create load exit].freeze
  CARDS_TYPE = %w[usual capitalist virtual].freeze
  MAIN_MENU_COMMANDS = %w[SC CC DC PM WM SM DA exit].freeze
  CARD_TYPES = {
    usual: 'usual',
    capitalist: 'capitalist',
    virtual: 'virtual'
  }.freeze
  CARD_NUMBER_AMOUNT = 16
  CARD_NUMBER_RANGE = 9
  COMMANDS = {
    create_account: 'create',
    load_account: 'load',
    show_cards: 'SC',
    card_create: 'CC',
    card_destroy: 'DC',
    put_money: 'PM',
    withdraw_money: 'WM',
    send_money: 'SM',
    delete_account: 'DA',
    exit: 'exit'
  }.freeze
  MIN_LOGIN_LENGTH = 4
  MAX_LOGIN_LENGTH = 20
  AGE_MIN = 23
  AGE_MAX = 90
  MIN_PASSWORD_LENGTH = 6
  MAX_PASSWORD_LENGTH = 30
end
