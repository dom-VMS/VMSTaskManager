# Determines whether a string is a number or not.
# Can determine numbers such as '1', '2.0', '1,000'
# Used in Search functions throughout the application
# i.e.) Searching for a Task via it's Task #.
def regex_is_number? string
  no_commas =  string.gsub(',', '')
  matches = no_commas.match(/-?\d+(?:\.\d+)?/)
  if !matches.nil? && matches.size == 1 && matches[0] == no_commas
    true
  else
    false
  end
end