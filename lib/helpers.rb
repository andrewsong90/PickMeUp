# Check for at least one non-empy json
def any_non_empty?(params)
  params.each do |param|
    return true if !param.blank?
  end

  return false
end
