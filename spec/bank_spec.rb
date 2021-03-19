RSpec.describe Bank do
  subject(:current_subject) { described_class.new }

  let(:test_file) { 'account.yml' }
  let(:directory_path) { 'BankStorage::STORAGE_DIRECTORY' }
  let(:filename) { 'BankStorage::STORAGE_FILE' }
  let(:db_test) { 'spec/fixtures' }

  describe '#console' do
    context 'when correct method calling' do
      after do
        current_subject.start_menu
      end

      it 'create account if input is create' do
        allow(current_subject.communication).to receive(:start_menu).and_return('create')
        expect(current_subject).to receive(:create)
      end

      it 'load account if input is load' do
        allow(current_subject.communication).to receive(:start_menu).and_return('load')
        expect(current_subject).to receive(:loading)
      end

      it 'leave app if input is exit or some another word' do
        allow(current_subject.communication).to receive(:start_menu).and_return('exit')
        expect(current_subject).to receive(:exit_command)
      end
    end
  end

  describe '#create' do
    let(:success_name_input) { 'Denis' }
    let(:success_age_input) { '72' }
    let(:success_login_input) { 'Denis' }
    let(:success_password_input) { 'Denis1993' }

    before do
      allow(current_subject.communication).to receive(:name_init).and_return(success_name_input)
      allow(current_subject.communication).to receive(:age_init).and_return(success_age_input)
      allow(current_subject.communication).to receive(:login_init).with(current_subject.accounts).and_return(success_login_input)
      allow(current_subject.communication).to receive(:password_init).and_return(success_password_input)
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
      Dir.mkdir(db_test)
    end

    context 'with success result' do
      after do
        File.delete(File.join(db_test, test_file))
        Dir.rmdir(db_test)
      end

      it 'write to file User_data instance' do
        allow(current_subject).to receive(:main_menu)

        current_subject.create
        expect(current_subject.store.data[:user]).not_to be(nil)
      end
    end
  end

  describe '#load' do
    context 'without inactive accounts' do
      before do
        stub_const(directory_path, db_test)
        stub_const(filename, test_file)
        allow(current_subject.communication).to receive(:login_search).with(current_subject.accounts)
        allow(current_subject.communication).to receive(:password_search).with(current_subject.accounts)
      end

      it do
        allow(current_subject.communication).to receive(:main_menu)
        current_subject.loading
        expect(current_subject.store.data[:user]).to eq([])
      end
    end

    context 'with active accounts' do
      let(:login) { 'Johnny' }
      let(:password) { 'johnny1' }

      before do
        allow(current_subject.communication).to receive(:start_menu).and_return('load')
        allow(current_subject.communication).to receive(:main_menu)
      end

      context 'when account exists' do
        let(:good_user_data) { UserData.new(name: 'Johnny', age: '29', login: login, password: password, card: []) }

        it do
          current_subject.store.data[:user] << good_user_data
          allow(current_subject.communication).to receive_message_chain(:login_search, :gets).and_return(login)
          allow(current_subject.communication).to receive_message_chain(:password_search, :gets).and_return(password)
          expect { current_subject }.not_to raise_error
          current_subject.start_menu
        end
      end
    end
  end

  describe '#main_menu' do
    let(:commands) do
      {
        'SC' => :show_cards,
        'CC' => :create_card,
        'DC' => :destroy_card,
        'PM' => :put_money,
        'WM' => :withdraw_money,
        'SM' => :send_money,
        'DA' => :destroy_account
      }
    end

    context 'when commands used' do
      let(:undefined_command) { 'undefined' }

      it 'calls specific methods on predefined commands' do
        commands.each do |command, method|
          allow(current_subject.communication).to receive(:main_menu).and_return(command)
          expect(current_subject.functions).to receive(method)
          current_subject.main_menu
        end
      end

      it 'calls exit command' do
        allow(current_subject.communication).to receive(:main_menu).and_return('exit')
        expect(current_subject).to receive(:exit_command)
        current_subject.main_menu
      end
    end
  end

  describe '#show_cards' do
    context 'When cards exist' do
      subject(:card_functions) { CardFunctions.new(current_acc, true, true) }

      let(:cards) { CardGenerator.new.cards('usual') }
      let(:current_acc) { UserData.new(name: 'Johnny', age: '29', login: 'login', password: 'password', card: [cards]) }

      it 'display cards if there are any' do
        expect(card_functions.communication.output).to receive(:show_cards).with(current_acc)
        card_functions.show_cards
      end
    end

    context 'When dontcards exist' do
      subject(:card_functions) { CardFunctions.new(current_acc_without_cards, true, true) }

      let(:current_acc_without_cards) do
        UserData.new(name: 'Johnny', age: '29', login: 'login', password: 'password', card: [])
      end

      it 'display cards if there are any' do
        expect(card_functions.communication.output).to receive(:no_cards)
        card_functions.show_cards
      end
    end
  end

  describe '#create_card' do
    subject(:card_functions) { CardFunctions.new(current_acc, storage, true) }

    let(:storage) { BankStorage.new }
    let(:current_acc) { UserData.new(name: 'Johnny', age: '29', login: 'login', password: 'password', card: []) }

    it 'create usual card' do
      allow(card_functions.store).to receive(:save)
      allow(card_functions.communication).to receive(:card_init).and_return('usual')
      card_functions.create_card
      expect(card_functions.current_account.card).not_to be_empty
    end

    it 'create capitalist card' do
      allow(card_functions.store).to receive(:save)
      allow(card_functions.communication).to receive(:card_init).and_return('capitalist')
      card_functions.create_card
      expect(card_functions.current_account.card).not_to be_empty
    end

    it 'create virtual card' do
      allow(card_functions.store).to receive(:save)
      allow(card_functions.communication).to receive(:card_init).and_return('virtual')
      card_functions.create_card
      expect(card_functions.current_account.card).not_to be_empty
    end
  end

  describe '#destroy_card' do
    before do
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
    end

    context 'without cards' do
      subject(:card_functions) { CardFunctions.new(without_card_data, storage, true) }

      let(:without_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [])
      end
      let(:storage) { BankStorage.new }

      after do
        File.delete(File.join(db_test, test_file))
        Dir.rmdir(db_test)
      end

      it 'shows message about not active cards' do
        expect(card_functions.communication.output).to receive(:no_cards)
        card_functions.destroy_card
      end
    end
  end

  context 'with cards' do
    subject(:card_functions) { CardFunctions.new(with_card_data, storage, true) }

    let(:with_card_data) do
      UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [card])
    end
    let(:storage) { BankStorage.new }
    let(:card) { CardGenerator.new.cards('usual') }

    it 'delete card' do
      allow(card_functions.communication).to receive(:serial_number_of_card).and_return('1')
      card_functions.destroy_card
      expect(card_functions.current_account.card).to be_empty
    end
  end

  describe 'put_money' do
    before do
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
    end

    after do
      File.delete(File.join(db_test, test_file))
      Dir.rmdir(db_test)
    end

    let(:card) { CardGenerator.new.cards('capitalist') }
    let(:storage) { BankStorage.new }

    context 'without cards' do
      subject(:card_functions) { CardFunctions.new(without_card_data, storage, true) }

      let(:without_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [])
      end

      it 'shows message about not active cards' do
        expect(card_functions.communication.output).to receive(:no_cards)
        card_functions.put_money
      end
    end

    context 'with cards' do
      subject(:card_functions) { CardFunctions.new(with_card_data, storage, true) }

      let(:with_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [card])
      end

      it 'put money on card' do
        allow(card_functions.communication).to receive(:serial_number_of_card).and_return(1)
        allow(card_functions.communication).to receive(:put_money_amount).and_return(200)
        card_functions.put_money
        expect(card_functions.current_account.card[0].balance).to be > 200
      end

      it 'exits the application when tax > input amount of money' do
        allow(card_functions.communication).to receive(:serial_number_of_card).and_return(1)
        allow(card_functions.communication).to receive(:put_money_amount).and_return(1)
        expect(card_functions).not_to receive(:add_money_to_card)
        card_functions.put_money
      end
    end
  end

  describe '#withdraw_money' do
    before do
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
    end

    after do
      File.delete(File.join(db_test, test_file))
      Dir.rmdir(db_test)
    end

    let(:card) { CardGenerator.new.cards('usual') }
    let(:storage) { BankStorage.new }

    context 'without cards' do
      subject(:card_functions) { CardFunctions.new(without_card_data, storage, true) }

      let(:without_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [])
      end

      it 'shows message about not active cards' do
        expect(card_functions.communication.output).to receive(:no_cards)
        card_functions.withdraw_money
      end

      context 'with cards' do
        subject(:card_functions) { CardFunctions.new(with_card_data, storage, true) }

        let(:with_card_data) do
          UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [card])
        end

        it 'put money on card' do
          allow(card_functions.communication).to receive(:serial_number_of_card).and_return(1)
          allow(card_functions.communication).to receive(:put_money_amount).and_return(10)
          card_functions.withdraw_money
          expect(card_functions.current_account.card[0].balance).to be < 50
        end
      end
    end
  end

  describe 'send money' do
    before do
      stub_const(directory_path, db_test)
      stub_const(filename, test_file)
    end

    after do
      File.delete(File.join(db_test, test_file))
      Dir.rmdir(db_test)
    end

    let(:card) { CardGenerator.new.cards('usual') }
    let(:storage) { BankStorage.new }

    context 'without cards' do
      subject(:card_functions) { CardFunctions.new(without_card_data, storage, true) }

      let(:without_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [])
      end

      it 'shows message about not active cards' do
        expect(card_functions.communication.output).to receive(:no_cards)
        card_functions.send_money
      end
    end

    context 'with cards' do
      subject(:card_functions) { CardFunctions.new(with_card_data, storage, accounts) }

      let(:accounts) { storage.data[:user] }
      let(:with_card_data) do
        UserData.new(name: 'Johnny', age: '29', login: 'qweqwe', password: 'qweqweqweqw', card: [card])
      end
      let(:another_card) { CardGenerator.new.cards('usual') }
      let(:another_account) do
        UserData.new(name: 'Johnny', age: '24', login: 'fwff', password: 'gerge', card: [another_card])
      end

      it 'shows message about not active cards' do
        card_functions.store.data[:user] << another_account
        allow(card_functions.communication).to receive(:serial_number_of_card).and_return(1)
        allow(card_functions.communication).to receive(:put_money_amount).and_return(30)
        recipient_card = another_account.card[0].number
        allow(card_functions.communication).to receive(:recipient_card_input).and_return(recipient_card)
        card_functions.send_money
        expect(card_functions.current_account.card[0].balance).to be < 50
      end
    end
  end

  describe 'communications' do
    subject(:communication) { Communication.new }

    context 'start_menu input' do
      let(:correct_comand) { 'create' }
      let(:incorrect_comand) { 'eww' }

      before do
        allow(communication.output).to receive(:welcome)
      end

      it 'test correct start_menu command' do
        allow(communication).to receive(:gets).and_return(correct_comand)
        expect(communication.start_menu).to eq(correct_comand)
      end

      it 'test incorrect start_menu command' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return(incorrect_comand, correct_comand)
        expect(communication.start_menu).to eq(correct_comand)
      end
    end

    context 'name_init input' do
      let(:correct_input) { 'Nikita' }

      it 'test correct name input' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.name_init).to eq(correct_input)
      end

      it 'test name with small first letter' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return(correct_input.downcase, correct_input)
        expect(communication.name_init).to eq(correct_input)
      end

      it 'test short name input' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return('e', correct_input)
        expect(communication.name_init).to eq(correct_input)
      end

      it 'test long name input' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return('qwdqwdqqdqwqwqwdqwqwde', correct_input)
        expect(communication.name_init).to eq(correct_input)
      end
    end

    context 'age_init input' do
      let(:correct_input) { '28' }

      it 'test correct age input' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.age_init).to eq(correct_input)
      end

      it 'test age < 23 ' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return('1', correct_input)
        expect(communication.age_init).to eq(correct_input)
      end

      it 'test age > 90' do
        allow(communication).to receive_message_chain(:gets, :chomp).and_return('200', correct_input)
        expect(communication.age_init).to eq(correct_input)
      end
    end

    context 'login_init input' do
      before do
        stub_const(directory_path, db_test)
        stub_const(filename, test_file)
      end

      after do
        File.delete(File.join(db_test, test_file))
        Dir.rmdir(db_test)
      end

      let(:accounts) { BankStorage.new.data[:user] }
      let(:some_account) { UserData.new(name: 'qqq', age: '29', login: 'qwerty', password: 'qwdqwdq', card: []) }
      let(:correct_input) { 'qwertyy' }
      let(:some_account) { UserData.new(name: 'qqq', age: '29', login: 'qwerty', password: 'qwdqwdq', card: []) }

      it 'test correct login input during registration' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.login_init(accounts)).to eq(correct_input)
      end

      it 'test login input wich already exsist during registration' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return('qwerty', correct_input)
        expect(communication.login_init(accounts)).to eq(correct_input)
      end

      it 'test login input < 4' do
        allow(communication).to receive(:gets).and_return('qwe', correct_input)
        expect(communication.login_init(accounts)).to eq(correct_input)
      end

      it 'test login input > 20' do
        allow(communication).to receive(:gets).and_return((21.times { 'k' }).to_s, correct_input)
        expect(communication.login_init(accounts)).to eq(correct_input)
      end
    end

    context 'password init ' do
      let(:correct_input) { 'nikitysik))' }

      it 'test correct login input during registration' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.password_init).to eq(correct_input)
      end

      it 'test password input < 6' do
        allow(communication).to receive(:gets).and_return('qwe', correct_input)
        expect(communication.password_init).to eq(correct_input)
      end

      it 'test login input > 30' do
        allow(communication).to receive(:gets).and_return((30.times { 'k' }).to_s, correct_input)
        expect(communication.password_init).to eq(correct_input)
      end
    end

    context 'login_search input' do
      before do
        stub_const(directory_path, db_test)
        stub_const(filename, test_file)
      end

      after do
        File.delete(File.join(db_test, test_file))
        Dir.rmdir(db_test)
      end

      let(:accounts) { BankStorage.new.data[:user] }
      let(:correct_input) { 'qwertyy' }
      let(:some_account) do
        UserData.new(name: 'qqq', age: '29', login: correct_input, password: correct_input, card: [])
      end

      it 'test coorect login input ' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.login_search(accounts)).to eq(correct_input)
      end

      it 'test incorrect login input ' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return('q', correct_input)
        expect(communication.login_search(accounts)).to eq(correct_input)
      end
    end

    context 'password_search input' do
      before do
        stub_const(directory_path, db_test)
        stub_const(filename, test_file)
        communication.instance_variable_set(:@login, 'qwerty')
      end

      after do
        File.delete(File.join(db_test, test_file))
        Dir.rmdir(db_test)
      end

      let(:accounts) { BankStorage.new.data[:user] }
      let(:correct_input) { 'qwertyy' }
      let(:some_account) { UserData.new(name: 'qqq', age: '29', login: 'qwerty', password: correct_input, card: []) }

      it 'test coorect password input ' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.password_search(accounts)).to eq(correct_input)
      end

      it 'test incorrect login input ' do
        accounts << some_account
        allow(communication).to receive(:gets).and_return('q', correct_input)
        expect(communication.password_search(accounts)).to eq(correct_input)
      end
    end

    context 'serial_number_of_card input' do
      let(:correct_input) { '1' }
      let(:card) { CardGenerator.new }
      let(:some_account) { UserData.new(name: 'qqq', age: '29', login: 'qwerty', password: 'wwwww', card: [card]) }

      it 'test coorect serial_number input ' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.serial_number_of_card(some_account)).to eq(correct_input.to_i)
      end

      it 'test incorrect serial_number input ' do
        allow(communication).to receive(:gets).and_return('2', correct_input)
        expect(communication.serial_number_of_card(some_account)).to eq(correct_input.to_i)
      end
    end

    context 'type of card input' do
      let(:correct_input) { 'usual' }

      it 'test correct type input ' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.card_init).to eq(correct_input)
      end

      it 'test incorrect type input ' do
        allow(communication).to receive(:gets).and_return('2', correct_input)
        expect(communication.card_init).to eq(correct_input)
      end
    end

    context 'main menu input' do
      let(:correct_input) { 'SC' }

      it 'test correct command input ' do
        allow(communication).to receive(:gets).and_return(correct_input)
        expect(communication.main_menu).to eq(correct_input)
      end

      it 'test incorrect command input ' do
        allow(communication).to receive(:gets).and_return('2', correct_input)
        expect(communication.main_menu).to eq(correct_input)
      end
    end
  end
end
