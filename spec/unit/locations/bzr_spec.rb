require 'spec_helper'

module Berkshelf
  describe BzrLocation do
    let(:dependency) { double(name: 'bacon') }

    subject do
      described_class.new(dependency, bzr: 'https://repo.com', 
                          ref: 'abc123', revid: 'test@test.net-20140320213448-r0103d8bgjlu5jyz')
    end

    describe '.initialize' do
      it 'sets the uri' do
        instance = described_class.new(dependency, bzr: 'https://repo.com')
        expect(instance.uri).to eq('https://repo.com')
      end

      it 'sets the ref' do
        instance = described_class.new(dependency,
          bzr: 'https://repo.com', ref: 'revno:2')
        expect(instance.ref).to eq('revno:2')
      end

      it 'sets the revid' do
        instance = described_class.new(dependency,
          bzr: 'https://repo.com', revid: 'test@test.net-20140320213448-r0103d8bgjlu5jyz')
        expect(instance.revid).to eq('test@test.net-20140320213448-r0103d8bgjlu5jyz')
      end

    end

    describe '#download' do
      before do
        CachedCookbook.stub(:from_store_path)
        FileUtils.stub(:cp_r)
        subject.stub(:validate_cached!)
        subject.stub(:validate_cookbook!)
        subject.stub(:bzr)
      end

      context 'when the cookbook is already installed' do
        it 'loads the cookbook from the store' do
          subject.stub(:installed?).and_return(true)
          expect(CachedCookbook).to receive(:from_store_path)
          expect(subject).to receive(:validate_cached!)
          expect(subject).to_not receive(:bzr)
          subject.download
        end
      end

      context 'when the repository is cached' do
        it 'pulls a new version' do
          Dir.stub(:chdir) { |args, &b| b.call } # Force eval the chdir block
          subject.stub(:cached?).and_return(true)
          expect(subject).to receive(:bzr).with('pull')
          subject.download
        end
      end

      context 'when the revision is not cached' do
        it 'clones the repository' do
          subject.stub(:cached?).and_return(false)
          expect(subject).to receive(:bzr).with('pull -r revid:test@test.net-20140320213448-r0103d8bgjlu5jyz')
          subject.download
        end
      end
    end

    describe '#scm_location?' do
      it 'returns true' do
        instance = described_class.new(dependency, bzr: 'https://repo.com')
        expect(instance).to be_scm_location
      end
    end

    describe '#==' do
      let(:other) { subject.dup }

      it 'returns true when everything matches' do
        expect(subject).to eq(other)
      end

      it 'returns false when the other location is not an BzrLocation' do
        other.stub(:is_a?).and_return(false)
        expect(subject).to_not eq(other)
      end

      it 'returns false when the uri is different' do
        other.stub(:uri).and_return('different')
        expect(subject).to_not eq(other)
      end

      it 'returns false when the ref is different' do
        other.stub(:ref).and_return('different')
        expect(subject).to_not eq(other)
      end
    end

    describe '#to_s' do
      it 'gives the revid' do
        expect(subject.to_s).to eq('https://repo.com (at test@test.net-20140320213448-r0103d8bgjlu5jyz)')
      end
    end

    describe '#to_lock' do
      it 'includes all the information' do
        expect(subject.to_lock).to eq <<-EOH.gsub(/^ {8}/, '')
            bzr: https://repo.com
            revid: test@test.net-20140320213448-r0103d8bgjlu5jyz
            ref: revno:2
        EOH
      end
    end

    describe '#bzr' do
      before { described_class.send(:public, :bzr) }

      it 'raises an error if Bazaar is not installed' do
        Berkshelf.stub(:which).and_return(false)
        expect { subject.bzr('foo') }.to raise_error(BzrLocation::BzrNotInstalled)
      end

      it 'raises an error if the command fails' do
        subject.stub(:`)
        $?.stub(:success?).and_return(false)
        expect { subject.bzr('foo') }.to raise_error(BzrLocation::BzrCommandError)
      end
    end
  end
end
