# Schedule the import of Ad datasets
every 1.hours do
  command "cd #{File.dirname File.absolute_path __FILE__}/../models && ruby ./import.rb"
end
