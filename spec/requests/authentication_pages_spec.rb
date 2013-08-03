require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('h1', text: 'Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting another page" do
        # サインイン失敗後に別ページ移動した時に、
        # flashに保存したメッセージが残っていないかテスト
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it { should have_selector('title', text: user.name) }

      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }

      it { should_not have_link('Sing in', href: signin_path)}

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }

        # サインインしていない状態で[Profile], [Settings]などの
        # リンクが表示されていないかテスト 演習9.6.3
        it { should_not have_link('Profile') }
        it { should_not have_link('Settings')}
      end
    end
  end

  describe "authorization" do
    # サインインしていない状態で、
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do
        # 編集ページを開く
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        # ユーザー情報を更新する
        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end
      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end
        
        # サインイン前にアクセスしたページに、
        # サインイン後遷移されているかテスト
        describe "after signing in" do
          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end

          # 再度サインアウト、サインインを行い
          # デフォルトのページが開くかテスト 演習 9.6.8
          describe "when signing in again" do
            before do
              delete signout_path
              visit signin_path
              fill_in "Email",    with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end

            it "should render the default(profile) page" do
              page.should have_selector('title', text: user.name)
            end
          end
        end
      end
    end

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      # サインインした後に、newやcreateアクションにアクセスした場合、
      # root_pathにリダイレクトされているかテスト 演習 9.6.6
      describe "when access new action redirected" do
        before { get new_user_path }
        specify { response.should redirect_to(root_path) }
      end

      describe "when access create action redirected" do
        before { post users_path }
        specify { response.should redirect_to(root_path) }
      end
    end


    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Usrs#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before do
        sign_in admin
      end

      # 管理者が自分自身を削除できないかテスト 演習 9.6.9
      describe "submitting a DELETE request to the User#destroy action" do
        it "hogehoge" do
          expect { delete user_path(admin) }.to change(User, :count).by(0)
        end
      end

    end
        
  end
end


