require 'rspec'
require 'data_merger'  # Replace with the actual name of your Ruby file

RSpec.describe 'CSVProcessor' do
  before(:each) do
    @test_input = 'test_input.csv'
    @test_output = 'test_output.csv'

    # Create a test input CSV
    CSV.open(@test_input, 'w') do |csv|
      csv << ['ID', 'Name', 'Car', 'Color']
      csv << ['1', 'John', 'Toyota', 'Red']
      csv << ['1', 'John', 'Honda', 'Blue']
      csv << ['2', 'Jane', 'Ford', 'Green']
      csv << ['3', 'Bob', 'Chevy', 'Red']
      csv << ['3', 'Bob', 'Chevy', 'Blue']
    end

    # Set global variables
    @file_path = @test_input
    @output_file = @test_output
    @processed_ids = Set.new
    @whitelisted_columns = Set.new
  end

  after(:each) do
    File.delete(@test_input) if File.exist?(@test_input)
    File.delete(@test_output) if File.exist?(@test_output)
  end

  it 'processes CSV and creates output file' do
    process
    expect(File.exist?(@test_output)).to be true
  end

  it 'correctly merges rows with matching IDs' do
    process
    output = CSV.read(@test_output, headers: true)

    expect(output.size).to eq(3)  # 3 unique IDs
    expect(output[0]['ID']).to eq('1')
    expect(output[0]['Car']).to eq('Toyota')
    expect(output[0]['Car_2']).to eq('Honda')
    expect(output[0]['Color']).to eq('Red')
    expect(output[0]['Color_2']).to eq('Blue')
  end

  it 'correctly handles rows without duplicates' do
    process
    output = CSV.read(@test_output, headers: true)

    expect(output[1]['ID']).to eq('2')
    expect(output[1]['Name']).to eq('Jane')
    expect(output[1]['Car']).to eq('Ford')
    expect(output[1]['Color']).to eq('Green')
    expect(output[1]['Car_2']).to be_nil
    expect(output[1]['Color_2']).to be_nil
  end

  it 'correctly identifies whitelisted columns' do
    process
    expect(@whitelisted_columns.to_a).to contain_exactly('Car', 'Color')
  end
end