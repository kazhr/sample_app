# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do

  before do
    @user = User.new(name:"Example User", email:"user@example.com",
                    password:"foobar", password_confirmation:"foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }

  it { should be_valid } # 正しい値が入力されていることをテスト
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "accessible attributes" do
    # admin属性にアクセス出来ないことテスト 演習9.6.1
    it "should not allow access to admin" do
      expect do
        User.new(admin: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid } # 不正な値が入力されていることをテスト
  end

  describe "when email is not present" do
    before { @user.email = " "}
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when email format is invalid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before do
      @user.password = @user.password_confirmation = " "
    end
    
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before do
      @user.password_confirmation = "mismatch"
    end

    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before do
      @user.password_confirmation = nil
    end

    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before do
      @user.password = @user.password_confirmation = "a" * 5 
    end

    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    # 最初にユーザーを保存する
    before { @user.save }
    # メールアドレスでユーザーを検索
    # ユーザーをfound_user変数にセットする
    let(:found_user) { User.find_by_email(@user.email) }

    # @userとfound_userが一致する場合
    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    # @userとfound_userが一致しない場合
    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      # specifyはitと同義 itを使用すると英語をして不自然な場合にこれで代用する
      specify { user_for_invalid_password.should be_false }
    end
  end

  # 記憶トークンが有効であること（空欄のない）をテストする
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

end
