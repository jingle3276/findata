json.extract! position,
  :id,
  :account_number,
  :account_name,
  :symbol,
  :quatity,
  :last_price,
  :current_value,
  :total_gain_loss_percent,
  :cost_basis_total,
  :date,
  :maturity_date,
  :created_at,
  :updated_at

json.formatted do
  json.quatity number_with_delimiter(position.quatity)
  json.last_price number_to_currency(position.last_price, precision: 2)
  json.current_value number_to_currency(position.current_value, precision: 2)
  json.total_gain_loss_percent number_to_percentage(position.total_gain_loss_percent, precision: 2)
  json.cost_basis_total number_to_currency(position.cost_basis_total, precision: 2)
  json.date position.date&.strftime("%Y-%m-%d")
  json.maturity_date position.maturity_date&.strftime("%Y-%m-%d")
end

json.url position_url(position, format: :json)
