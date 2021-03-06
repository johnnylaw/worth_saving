class Admin::PagesController < AdminController
  def new
    @page = Page.new user: current_user
    build_subpage

    render 'pages/form'
  end

  def create
    @page = Page.new page_params
    if @page.save
      flash[:message] = 'Congratulations!'
      redirect_to edit_admin_page_path @page
    else
      flash[:error] = 'Could not save'
      render 'form'
    end
  end

  def edit
    @page = Page.find params[:id]
    build_subpage

    render 'pages/form'
  end

  def update
    @page = Page.find params[:id]
    @page.update_attributes page_params
    redirect_to edit_admin_page_path @page
  end

  private

  def page_params
    if WorthSaving::Info.attribute_whitelisting_required?
      params[:page]
    else
      params.require(:page).permit(
        :user_id, :title, :content, :approved, :page_type, :position, :subpages_attributes
      )
    end
  end

  def build_subpage
    @page.subpages.present? || @page.subpages.build
  end
end