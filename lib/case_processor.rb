require 'csv'
require 'active_support/core_ext/string'

class CaseProcessor
  def initialize(file_path)
    @file_path = file_path
  end

  def process
    CSV.read(@file_path, headers: true)
  end

  def active_support_works
    @text = "Active Support works, it really really works!!!"
    @text.truncate(6)
  end

  def num_cases
    process.count
  end

  def count_partners(partner)
    process.count { |row| row['Lawyer'] == partner }
  end

  def alert_empty
    puts find_empty_cells
  end

  def find_empty_cells
    process.each_with_index.flat_map do |row, row_index|
      find_empty_cells_in_row(row, row_index)
    end
  end

  private

  def find_empty_cells_in_row(row, row_index)
    row.headers.map do |column|
      create_empty_cell_info(row, column, row_index) if cell_empty?(row[column])
    end.compact
  end

  def cell_empty?(value)
    value.nil? || value.strip.empty?
  end

  def create_empty_cell_info(row, column, row_index)
    {
      row: row_index + 2,
      column: column,
      case_number: row['CaseNumber']
    }
  end

end
@case_processor = CaseProcessor.new('./sample_cases.csv')
puts "Number of cases: #{@case_processor.num_cases}\n"
@case_processor.alert_empty
