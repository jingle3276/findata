json.positions @positions do |position|
  json.partial! "positions/position", position: position
end
