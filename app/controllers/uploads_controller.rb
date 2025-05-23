class UploadsController < ApplicationController
  def index
  end

  def create
    if params[:file].present?
      csv_path = params[:file].path
      ProcessPositionsCsvJob.perform_async(csv_path)
      redirect_to positions_path, notice: "CSV file is being processed"
    else
      redirect_to uploads_path, alert: "Please select a file to upload"
    end
  end
end
