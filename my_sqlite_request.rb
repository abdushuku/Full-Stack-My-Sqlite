require 'csv'

class MySqliteRequest
  def initialize
    @table_name = nil
    @select_columns = []
    @where_conditions = {}
    @data = []
    @data_loaded = false
    @data_written = false
  end

  def from(file_name)
    @table_name = file_name
    self
  end

  def select(*columns)
    @select_columns.concat(columns)
    self
  end

  def where(column, value)
    @where_conditions[column] = value
    self
  end

  def insert(data)
    @data << data
    @data_written = true
    self
  end

  def update(column, value, new_data)
    @data.each do |row|
      row[column] = new_data if row[column] == value
    end
    @data_written = true
    self
  end

  def delete(column, value)
    @data.reject! { |row| row[column] == value }
    @data_written = true
    self
  end

  def run
    load_data unless @data_loaded
    filter_data
    select_columns
    write_data if @data_written
    @result
  end

  private

  def load_data
    @data = CSV.read(@table_name, headers: true)
    @data_loaded = true
  end

  def filter_data
    return if @where_conditions.empty?

    @data.select! do |row|
      @where_conditions.all? { |column, value| row[column] == value }
    end
  end

  def select_columns
    @result = @data.map { |row| row.to_h.slice(*@select_columns) }
  end

  def write_data
    CSV.open(@table_name, "w") do |csv|
      csv << @data.headers if @data.respond_to?(:headers) && @select_columns.empty?
      @data.each { |row| csv << row }
    end
  end
  
end
