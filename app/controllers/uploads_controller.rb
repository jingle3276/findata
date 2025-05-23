class UploadsController < ApplicationController
  def index
  end

  def create
    if params[:file].present?
      # Create a unique filename
      filename = "positions_#{Time.current.to_i}.csv"
      upload_path = Rails.root.join("tmp", "uploads", filename)

      # Ensure directory exists
      FileUtils.mkdir_p(File.dirname(upload_path))

      # Copy uploaded file to persistent location
      File.open(upload_path, "wb") do |file|
        file.write(params[:file].read)
      end

      # Enqueue job with persistent file path
      ProcessPositionsCsvJob.perform_async(upload_path.to_s)

      redirect_to positions_path, notice: "CSV file is being processed"
    else
      redirect_to uploads_path, alert: "Please select a file to upload"
    end
  end
end
