# frozen_string_literal: true

require 'register_common/adapters/athena_adapter'

RSpec.describe RegisterCommon::Adapters::AthenaAdapter do
  subject { described_class.new(credentials:) }

  let(:credentials) do
    double(
      'credentials',
      AWS_REGION: 'AWS_REGION',
      AWS_ACCESS_KEY_ID: 'AWS_ACCESS_KEY_ID',
      AWS_SECRET_ACCESS_KEY: 'AWS_SECRET_ACCESS_KEY'
    )
  end
  let(:athena_client) { double 'athena_client' }

  # rubocop:disable RSpec/ExpectInHook
  before do
    expect(Aws::Athena::Client).to receive(:new).with(
      region: credentials.AWS_REGION,
      access_key_id: credentials.AWS_ACCESS_KEY_ID,
      secret_access_key: credentials.AWS_SECRET_ACCESS_KEY
    ).and_return athena_client
  end
  # rubocop:enable RSpec/ExpectInHook

  describe '#get_query_execution' do
    it 'calls athena client' do
      execution_id = double 'execution_id'
      expected_response = double 'expected_response'

      expect(athena_client).to receive(:get_query_execution).with(
        { query_execution_id: execution_id }
      ).and_return expected_response

      response = subject.get_query_execution(execution_id)
      expect(response).to eq expected_response
    end
  end

  describe '#start_query_execution' do
    it 'calls athena client' do
      params = double 'params'
      expected_response = double 'expected_response'

      expect(athena_client).to receive(:start_query_execution).with(
        params
      ).and_return expected_response

      response = subject.start_query_execution(params)
      expect(response).to eq expected_response
    end
  end

  describe '#wait_for_query' do
    let(:execution_id) { double 'execution_id' }
    let(:states) { ['SUCCEEDED'] }
    let(:max_time) { states.length }
    let(:wait_interval) { 0.01 }

    let(:response) do
      subject.wait_for_query(execution_id, max_time:, wait_interval:)
    end

    let(:responses) do
      states.map do |state|
        double 'expected_response',
               query_execution: double('query_execution', status: double('state', state:))
      end
    end

    # rubocop:disable RSpec/ExpectInHook
    before do
      expect(athena_client).to receive(:get_query_execution).with(
        { query_execution_id: execution_id }
      ).and_return(*responses)
    end
    # rubocop:enable RSpec/ExpectInHook

    context 'when query has already completed' do
      it 'returns' do
        expect(response).to eq responses.last
      end
    end

    context 'when query has already failed' do
      let(:states) { ['FAILED'] }

      it 'returns' do
        expect { response }.to raise_error described_class::QueryTimeoutError
      end
    end

    context 'when query eventually completes' do
      let(:states) { %w[PENDING PENDING SUCCEEDED] }

      it 'returns' do
        expect(response).to eq responses.last
      end
    end
  end
end
