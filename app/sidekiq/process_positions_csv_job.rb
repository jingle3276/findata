class ProcessPositionsCsvJob
  include Sidekiq::Job

  def perform(csv_file_path)
    require 'csv'

    CSV.foreach(csv_file_path, headers: true, header_converters: :symbol) do |row|
      Position.create!(
        account_number: row[:account_number],
        account_name: row[:account_name],
        symbol: row[:symbol],
        quantity: row[:quantity]&.gsub(',', ''),
        last_price: row[:last_price]&.gsub('$', '')&.gsub(',', ''),
        current_value: row[:current_value]&.gsub('$', '')&.gsub(',', ''),
        total_gain_loss_percent: row[:total_gain_loss_percent]&.gsub('%', ''),
        cost_basis_total: row[:cost_basis_total]&.gsub('$', '')&.gsub(',', ''),
        date: Date.today
      )
    end
  rescue StandardError => e
    Rails.logger.error("Failed to process CSV row: #{e.message}")
    raise
  end
end