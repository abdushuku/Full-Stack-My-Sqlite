require_relative 'my_sqlite_request'

puts "MySQLite version 0.1 #{Time.now.strftime("%Y-%m-%d")}"

loop do
  print "my_sqlite_cli> "
  input = gets.chomp
  break if input == 'quit'
  parts = input.split(" ")
  case parts[0]
  when 'SELECT'
    columns = parts[1].split(",")
    file_index = parts.index('FROM')
    if file_index && file_index + 1 < parts.length
      file_name = parts[file_index + 1].delete_suffix(';')
      conditions = parts[(file_index + 2)..-1].each_slice(2).to_h
      request = MySqliteRequest.new.from(file_name).select(*columns)
      conditions.each { |column, value| request = request.where(column, value) }
      result = request.run
      puts result
    else
      puts "Error: Invalid SELECT command format"
    end
  when 'INSERT'
    file_name = parts[2]
    columns_values = parts[3..-1].each_slice(2).to_a
    data = Hash[columns_values]
    request = MySqliteRequest.new.from(file_name).insert(data)
    result = request.run
    puts "Inserted #{data} into #{file_name}"
  when 'UPDATE'
    file_name = parts[1]
    column = parts[2]
    value = parts[4]
    new_data = parts[6]
    request = MySqliteRequest.new.from(file_name).update(column, value, new_data)
    result = request.run
    puts "Updated #{column} to #{new_data} where #{column} equals #{value} in #{file_name}"
  when 'DELETE'
    file_name = parts[2]
    column = parts[3]
    value = parts[5]
    request = MySqliteRequest.new.from(file_name).delete(column, value)
    result = request.run
    puts "Deleted rows where #{column} equals #{value} from #{file_name}"
  else
    puts "Invalid command"
  end
end
