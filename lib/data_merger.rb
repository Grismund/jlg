require 'csv'

@file_path = './data.csv'
@output_file = './output.csv'
@processed_ids = Set.new
@whitelisted_columns = Set.new

def process
  output_rows = []

  CSV.foreach(@file_path, headers: true) do |row|
    id = row.fields.first

    next if @processed_ids.include?(id)

    @processed_ids.add(id)

    rows_with_matching_ids = find_rows_with_matching_ids(id)

    if rows_with_matching_ids.size == 1
      output_rows << row
    else
      whitelist_columns(rows_with_matching_ids)
      output_rows << merge_rows(rows_with_matching_ids)
    end
  end

  write_output(output_rows)
  puts "Whitelisted columns: #{@whitelisted_columns.to_a}"
end

def merge_rows(rows)
  merged_row = rows.first.to_h

  @whitelisted_columns.each do |column|
    values = rows.map { |row| row[column] }.uniq.compact

    # Keep the original value in the main column
    merged_row[column] = values.first

    # Add additional columns for multiple values
    (1...values.size).each do |i|
      merged_row["#{column}_#{i+1}"] = values[i]
    end
  end

  merged_row
end

def write_output(rows)
  CSV.open(@output_file, 'w') do |csv|
    headers = rows.first.keys
    csv << headers  # Write headers

    rows.each do |row|
      csv << headers.map { |header| row[header] }
    end
  end
end

private

def find_rows_with_matching_ids(target_id)
  rows_with_matching_ids = []
  CSV.foreach(@file_path, headers: true) do |row|
    rows_with_matching_ids << row if row.fields.first == target_id
  end
  rows_with_matching_ids
end

def whitelist_columns(rows_with_matching_ids)
  headers = rows_with_matching_ids.first.headers

  headers.each_with_index do |header, index|
    next if index == 0  # Skip the ID column

    values = rows_with_matching_ids.map { |row| row[header] }

    if values.uniq.size > 1
      @whitelisted_columns.add(header)
    end
  end
end

# Usage
process