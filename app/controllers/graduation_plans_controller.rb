class GraduationPlansController < ApplicationController
  def index
    @advisee = Advisee.find(params[:advisee_id])
    @graduation_plans = @advisee.graduation_plans
  end

  def new
    @advisee = Advisee.find(params[:advisee_id])
    @graduation_plan = GraduationPlan.new
  end

  def create
    @advisee = Advisee.find(params[:advisee_id])
    @graduation_plan = @advisee.graduation_plans.new(grad_plan_params)

    if @graduation_plan.save
      flash[:success] = 'Graduation plan created!'
      redirect_to advisee_graduation_plans_path(@advisee)
    else
      flash[:error] = 'There was a problem with that graduation plan'
      @errors = @graduation_plan.errors.full_messages
      render 'graduation_plans/new'
    end
  end

  private

  def grad_plan_params
    params.require(:graduation_plan).permit(:name)
  end
end