json.array!(@claimants) do |claimant|
  json.extract! claimant, :id, :first_name, :last_name, :email
  json.url claimant_url(claimant, format: :json)
end
