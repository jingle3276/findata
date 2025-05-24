class PositionsController < ApplicationController
  before_action :set_position, only: [ :edit, :update, :destroy ]

  # GET /positions
  def index
    base_scope = Position.all
    base_scope = base_scope.order(maturity_date: params[:sort_direction] || :asc) if params[:sort] == "maturity_date"

    @active_positions = base_scope.where("maturity_date > ?", Date.current)
    @matured_positions = base_scope.where("maturity_date <= ?", Date.current)

    respond_to do |format|
      format.html
      format.json { render json: { active: @active_positions, matured: @matured_positions } }
    end
  end

  # GET /positions/new
  def new
    @position = Position.new
  end

  # GET /positions/1/edit
  def edit
  end

  # POST /positions
  def create
  end

  # PATCH/PUT /positions/1
  def update
  end

  # DELETE /positions/1
  def destroy
    if @position.destroy
      respond_to do |format|
        format.html { redirect_to positions_url, notice: "Position was successfully deleted." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to positions_url, alert: @position.errors.full_messages.to_sentence }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def position_params
      params.require(:position).permit(
        :account_number,
        :account_name,
        :symbol,
        :quatity,
        :last_price,
        :current_value,
        :total_gain_loss_percent,
        :cost_basis_total,
        :date,
        :maturity_date
      )
    end
end
