class IssuesController < ApplicationController
  def index
    @user = User.find_by username: params[:username]
    @project = Project.find_by user_id: @user.id, name: params[:project]
    @activetab = 0
    @issuestoshow = @project.issues.where(status: 0)
    if params[:state] == 'closed'
      @activetab = 1
      @issuestoshow = @project.issues.where(status: 1)
    end
  end

  def new
    @user = User.find_by username: params[:username]
    @project = Project.find_by user_id: @user.id, name: params[:project]
    @issue = Issue.new
  end

  def show
    @user = User.find_by username: params[:username]
    @project = Project.find_by user_id: @user.id, name: params[:project]
    @issue = Issue.find_from_project(@project, params[:sub_id])
    @comments = Comment.where(
      polycomment_type: 'issue',
      polycomment_id: @issue.id
    )
    @comments = @comments.paginate(page: params[:page], per_page: 10)
    @comments = pg @comments, 10
    @comment = Comment.new
    @ajax = params[:page].nil? || params[:page] == 1
  end

  def create
    @user = User.find_by username: params[:username]
    @project = Project.find_by user_id: @user.id, name: params[:project]
    @issue = Issue.new(issue_params)
    @issue.user = current_user
    @issue.project = @project
    @issue.status = 0
    if @issue.save
      redirect_to(@project.urlbase)
    else
      flash[:alert] = "Couldn't create an issue"
      redirect_to(dashboard_path)
    end
  end

  def close
    @user = User.find_by username: params[:username]
    @project = Project.find_by user_id: @user.id, name: params[:project]
    @issue = Issue.find_from_project(@project, params[:sub_id])
    if (current_user == @project.user) || (current_user == @issue.user)
      @issue.status = 1
      @issue.save
      flash[:notice] = 'Issue Closed'
      redirect_to(@project.issues_url)
    else
      flash[:alert] = "You don't have permission to close this issue"
      redirect_to(@project.issues_url)
    end

  end

  private

  def issue_params
    params.require(:issue).permit(:title, :description, :type)
  end
end
