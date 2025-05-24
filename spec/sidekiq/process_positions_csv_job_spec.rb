require 'rails_helper'

RSpec.describe ProcessPositionsCsvJob, type: :job do
  let(:csv_file_path) { Rails.root.join('spec/sidekiq/mock_positions.csv') }

  describe '#perform' do
    it 'processes only treasury positions from CSV file' do
      expect {
        described_class.new.perform(csv_file_path.to_s)
      }.to change(Position, :count).by(13) # Only treasury positions (912xxx)

      # Test zero coupon treasury
      zero_coupon = Position.find_by(symbol: '912833LV0')
      expect(zero_coupon).to have_attributes(
        account_number: 'A10000001',
        account_name: 'Individual Account',
        quantity: 75000.0,
        last_price: 99.729,
        current_value: 74796.75,
        total_gain_loss_percent: 0.10,
        cost_basis_total: 74716.87,
        maturity_date: Date.new(2025, 5, 15)
      )

      # Test treasury note
      treasury_note = Position.find_by(symbol: '91282CMU2')
      expect(treasury_note).to have_attributes(
        account_number: 'A10000001',
        account_name: 'Individual Account',
        quantity: 10000.0,
        last_price: 100.274,
        current_value: 10027.40,
        total_gain_loss_percent: 0.72,
        cost_basis_total: 9955.20,
        maturity_date: Date.new(2030, 3, 31)
      )

      # Verify non-treasury positions were not imported
      expect(Position.where(symbol: [ 'SPAXX**', 'FDRXX**', '3130B5PU6' ])).to be_empty
    end

    it 'updates existing positions instead of creating duplicates' do
      # Create existing position
      existing = Position.create!(
        account_number: 'A10000001',
        account_name: 'Individual Account',
        symbol: '912833LV0',
        quantity: 70000.0,
        last_price: 98.0,
        current_value: 70000.0,
        total_gain_loss_percent: 0.0,
        cost_basis_total: 70000.0,
        date: Date.yesterday,
        maturity_date: Date.new(2025, 5, 15)
      )

      expect {
        described_class.new.perform(csv_file_path.to_s)
      }.to change(Position, :count).by(12) # 13 treasuries - 1 existing

      # Verify existing position was updated
      existing.reload
      expect(existing).to have_attributes(
        quantity: 75000.0,
        last_price: 99.729,
        current_value: 74796.75,
        total_gain_loss_percent: 0.10,
        cost_basis_total: 74716.87
      )
    end

    it 'extracts maturity dates from descriptions' do
      described_class.new.perform(csv_file_path.to_s)

      expect(Position.find_by(symbol: '912833LV0').maturity_date).to eq(Date.new(2025, 5, 15))
      expect(Position.find_by(symbol: '91282CMU2').maturity_date).to eq(Date.new(2030, 3, 31))
      expect(Position.find_by(symbol: '912810UJ5').maturity_date).to eq(Date.new(2045, 2, 15))
    end
  end
end
