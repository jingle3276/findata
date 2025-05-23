class ProcessPositionsCsvJob
  include Sidekiq::Job

  def perform(csv_file_path)
    require "csv"

    CSV.foreach(csv_file_path, headers: true) do |row|
      # Skip rows without required fields
      next if row["Account Number"].blank? || row["Symbol"].blank?

      # First try to find an existing position
      position = Position.find_or_initialize_by(
        account_number: row["Account Number"],
        symbol: row["Symbol"]
      )

      # Update attributes
      position.assign_attributes(
        account_name: row["Account Name"],
        quantity: parse_number(row["Quantity"]),
        last_price: parse_number(row["Last Price"]),
        current_value: parse_currency(row["Current Value"]),
        total_gain_loss_percent: parse_percentage(row["Total Gain/Loss Percent"]),
        cost_basis_total: parse_currency(row["Cost Basis Total"]),
        maturity_date: extract_maturity_date(row["Description"]),
        date: Date.today
      )

      position.save!
    end
  rescue StandardError => e
    Rails.logger.error("Failed to process CSV row: #{e.message}")
    raise
  end

  private

  def extract_maturity_date(description)
    return nil if description.blank?

    # Match patterns like "05/15/2025" or "02/15/2045"
    if match = description.match(%r{(\d{2}/\d{2}/\d{4})}i)
      Date.strptime(match[1], "%m/%d/%Y")
    else
      nil
    end
  end

  def parse_number(value)
    return nil if value.blank?
    value.to_s.gsub(/[,$]/, "").to_f
  end

  def parse_currency(value)
    return nil if value.blank?
    value.to_s.gsub(/[,$]/, "").to_f
  end

  def parse_percentage(value)
    return nil if value.blank?
    value.to_s.gsub(/[%+]/, "").to_f
  end
end
