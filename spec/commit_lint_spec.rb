require File.expand_path('../spec_helper', __FILE__)

module Danger
  class DangerCommitLint
    describe 'DangerCommitLint' do
      it 'should be a plugin' do
        expect(Danger::DangerCommitLint.new(nil)).to be_a Danger::Plugin
      end
    end

    describe 'check' do
      before do
        @dangerfile = testing_dangerfile
        @commit_lint = @dangerfile.commit_lint
        allow(@dangerfile.git).to receive(:commits).and_return([commit])
      end

      let(:commit) { double(:commit, message: message) }

      context 'with a long subject line' do
        let(:message) { 'This is a really long subject line and should result in an error' } # rubocop:disable Metrics/LineLength

        it 'adds an error for the subject_line check' do
          @commit_lint.check

          status_report = @commit_lint.status_report

          expect(status_report[:errors].count).to eq 1
          expect(status_report[:warnings].count).to eq 0
          expect(status_report[:messages].count).to eq 0
          expect(status_report[:markdowns].count).to eq 0

          expect(status_report[:errors]).to eq [ERROR_MESSAGES[:subject_length]]
        end
      end

      context 'with a period at the end of the subject line' do
        let(:message) { 'This subject line ends in a period.' }

        it 'adds an error for the subject_period check' do
          @commit_lint.check

          status_report = @commit_lint.status_report

          expect(status_report[:errors].count).to eq 1
          expect(status_report[:warnings].count).to eq 0
          expect(status_report[:messages].count).to eq 0
          expect(status_report[:markdowns].count).to eq 0

          expect(status_report[:errors]).to eq [ERROR_MESSAGES[:subject_period]]
        end
      end

      context 'without an empty line between subject and body' do
        let(:message) { "This subject line is fine\nBut then I forgot the empty line separating the subject and the body." } # rubocop:disable Metrics/LineLength

        it 'adds an error for the empty_line check' do
          @commit_lint.check

          status_report = @commit_lint.status_report

          expect(status_report[:errors].count).to eq 1
          expect(status_report[:warnings].count).to eq 0
          expect(status_report[:messages].count).to eq 0
          expect(status_report[:markdowns].count).to eq 0

          expect(status_report[:errors]).to eq [ERROR_MESSAGES[:empty_line]]
        end
      end

      context 'with a valid commit message' do
        let(:message) { "This is a valid message\n\nYou can tell because it meets all the criteria and the linter does not complain." } # rubocop:disable Metrics/LineLength

        it 'does nothing' do
          @commit_lint.check

          status_report = @commit_lint.status_report

          expect(status_report[:errors].count).to eq 0
          expect(status_report[:warnings].count).to eq 0
          expect(status_report[:messages].count).to eq 0
          expect(status_report[:markdowns].count).to eq 0
        end
      end
    end
  end
end
