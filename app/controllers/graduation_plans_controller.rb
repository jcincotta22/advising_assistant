class GraduationPlansController < ApplicationController
  before_filter :authenticate_user!
  before_filter only: [:index] do
    check_permissions(Advisee.find(params[:advisee_id]))
  end
  before_filter only: [:show, :destroy] do
    check_permissions(GraduationPlan.find(params[:id]).advisee)
  end

  def index
    @advisee = Advisee.find(params[:advisee_id])
    @graduation_plans = @advisee.graduation_plans
  end

  def show
    @graduation_plan = GraduationPlan.find(params[:id])
    @advisee = @graduation_plan.advisee
  end

  def new
    @advisee = Advisee.find(params[:advisee_id])
    @graduation_plan = GraduationPlan.new
  end

  def create
    @advisee = Advisee.find(params[:advisee_id])
    @graduation_plan = @advisee.graduation_plans.new(grad_plan_params)

    if @graduation_plan.save
      @graduation_plan.create_default_semesters

      flash[:success] = 'Graduation plan created!'
      redirect_to graduation_plan_path(@graduation_plan)
    else
      flash[:error] = 'There was a problem with that graduation plan'
      @errors = @graduation_plan.errors.full_messages
      render 'graduation_plans/new'
    end
  end

  def destroy
    graduation_plan = GraduationPlan.find(params[:id])
    advisee = graduation_plan.advisee

    graduation_plan.destroy

    flash[:success] = 'Graduation plan deleted!'
    redirect_to advisee_graduation_plans_path(advisee)
  end

  private

  def grad_plan_params
    params.require(:graduation_plan).permit(:name)
  end
end
