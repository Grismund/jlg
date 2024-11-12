require 'case_processor'

RSpec.describe CaseProcessor do
  describe '#process' do
    it 'reads the CSV file' do
      processor = CaseProcessor.new('sample_cases.csv')
      expect(processor.process).to be_a(CSV::Table)
    end

    it 'correctly counts the number of cases' do
      processor = CaseProcessor.new('sample_cases.csv')
      result = processor.num_cases
      expect(result).to eq(5)
    end

    it 'calculates the total balance' do
      processor = CaseProcessor.new('sample_cases.csv')
      result = processor.process
      total_balance = result['Balance'].map(&:to_f).sum
      expect(total_balance).to be_within(0.01).of(6897.96)
    end

    it 'totals the number of cases a partner has' do
      processor = CaseProcessor.new('sample_cases.csv')
      result = processor.count_partners("Nelson")
      expect(result).to eq(3)
    end
  end
end