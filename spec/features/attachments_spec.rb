require 'spec_helper'

feature "Attachments" do
  include SessionSteps

  before do
    @user = create :user_with_account
    @group = create :group
    @page = @group.child_pages.create
    @attachment = create :attachment, parent_id: @page.id, parent_type: 'Page'
  end

  context "when the user has the right to download the attachment" do
    before do
      @group << @user
      login @user
    end
    scenario "download the attachment" do
      visit @attachment.file.url
      # Checking the pdf content will raise an error, "invalid byte sequence in UTF-8",
      # because this test tool can't read the pdf. But the error means, the pdf has
      # been opened successfully, i.e. no "access denied".
      #
      expect { page.has_no_content? I18n.t(:access_denied) }.to raise_error(ArgumentError)
    end
  end

  context "when the user has no right to download the attachment" do
    before do
      login @user
    end
    scenario "download the attachment", :js do
      visit @attachment.file.url
      page.should have_content I18n.t(:access_denied)
    end
  end

  context "when the attachment has an author" do
    before do
      @group << @user
      login @user
    end
    scenario "description of the attachment", :js do
      visit @page
      page.should have_content @user.title
    end
  end

  context "when the attachment has no author" do
    before do
      @group << @user
      login @user
    end
    scenario "description of the attachment", :js do
      visit @page
      page.should have_no_content @user.title
    end
  end
end