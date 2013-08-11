require 'spec_helper'

describe "Static pages" do
  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_selector('h1', text: 'Sample App') }
    it { should have_selector('title', text: full_title('')) }
    it { should_not have_selector('title', text: 'Home') }
  end

  describe "Help page" do
    before { visit help_path }

    it { should have_selector('h1', text: 'Help') }
    it { should have_selector('title', text: full_title('Help')) }
  end

  describe "About page" do
    before { visit about_path }

    it { should have_selector('h1', text: 'About Us') }
    it { should have_selector('title', text: full_title('About')) }
  end

  describe "Contact pgae" do
    before { visit contact_path }

    it { should have_selector('h1', text:'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end

  describe "for signed-in users" do
    let(:user) { FactoryGirl.create(:user) }

    describe "should render the user's feed" do
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed for correct selector" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
    end

    describe "shuld render the correct micropost count" do
      context "for singular" do
        before do
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
          sign_in user
          visit root_path
        end
        it { should have_content("1 micropost") }
      end

      context "for multiple" do
        before do
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
          FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
          sign_in user
          visit root_path
        end

        it { should have_content("2 microposts") }
      end
    end

    describe "should render the correct pagination" do
      before do
        31.times { FactoryGirl.create(:micropost, user: user) }

        sign_in user
        visit root_path
      end

      it "should have 30 microposts at page 1" do
        count = 0
        user.microposts.paginate(page: 1).each do |micropost|
          expect(page).to have_selector('li', text: micropost.content)
          count += 1
        end
        expect(count).equal? 30
      end
      
      it "should have 1 microposts at page 2" do
        count = 0
        user.microposts.paginate(page: 2).each do |micropost|
          expect(page).to have_selector('li', text: micropost.content)
          count += 1
        end
        expect(count).equal? 1
      end
    end
  end
end
