require 'spec_helper'

module Berkshelf
  describe BzrLocation do
    let(:dependency) { double(name: 'bacon') }

    subject do
      described_class.new(dependency, bzr: 'https://repo.com',
                          ref: 'revno:2', revision: 'revid:test@test.net-20140320213448-r0103d8bgjlu5jyz')
    end

    describe '.initialize' do
      it 'sets the uri' do
        instance = described_class.new(dependency, bzr: 'https://repo.com')
        expect(instance.uri).to eq('https://repo.com')
      end

      it 'sets the ref' do
        instance = described_class.new(dependency,
          bzr: 'https://repo.com', ref: 'revno:1')
        expect(instance.ref).to eq('revno:1')
      end

      it 'sets the revision' do
        instance = described_class.new(dependency,
          bzr: 'https://repo.com', revision: 'revid:test@test.net-20140320213448-r0103d8bgjlu5jyz')
        expect(instance.revision).to eq('revid:test@test.net-20140320213448-r0103d8bgjlu5jyz')
      end

    end

    describe '#installed?' do
      it 'returns false when there is no revision' do
        allow(subject).to receive(:revision).and_return(nil)
        expect(subject.installed?).to be_falsey
      end
      it 'returns false when the install_path does not exist' do
        allow(subject).to receive(:revision).and_return('abcd1234')
        allow(subject).to receive(:install_path).and_return(double(exist?: false))
        expect(subject.installed?).to be false
      end

      it 'returns true when the location is installed' do
        allow(subject).to receive(:revision).and_return('abcd1234')
        allow(subject).to receive(:install_path).and_return(double(exist?: true))
        expect(subject.installed?).to be true
      end
    end

    describe '#install' do
      before do
        allow(CachedCookbook).to receive(:from_store_path)
        allow(FileUtils).to receive(:cp_r)
        allow(File).to receive(:chmod)
        allow(subject).to receive(:validate_cached!)
        allow(subject).to receive(:validate_cookbook!)
        allow(subject).to receive(:bzr)
      end

      context 'when the repository is cached' do
        it 'pulls a new version' do
          allow(Dir).to receive(:chdir).and_yield
          allow(subject).to receive(:cached?).and_return(true)
          allow(subject).to receive(:valid?).and_return(true)
          expect(subject).to receive(:bzr).with('pull')
          subject.install
        end
      end

      context 'when the revision is not cached' do
        it 'clones the repository' do
          allow(Dir).to receive(:chdir).and_yield
          allow(subject).to receive(:cached?).and_return(false)
          allow(FileUtils).to receive(:mkdir_p)
          expect(subject).to receive(:bzr).with(/branch https:\/\/repo.com .*/)
          subject.install
        end
      end
    end

    describe '#cached_cookbook' do
      it 'returns nil if the cookbook is not installed' do
        allow(subject).to receive(:installed?).and_return(false)
        expect(subject.cached_cookbook).to be_nil
      end

      it 'returns the cookbook at the install_path' do
        allow(subject).to receive(:installed?).and_return(true)
        allow(CachedCookbook).to receive(:from_path)

        expect(CachedCookbook).to receive(:from_path).once
        subject.cached_cookbook
      end
    end

    describe '#==' do
      let(:other) { subject.dup }

      it 'returns true when everything matches' do
        expect(subject).to eq(other)
      end

      it 'returns false when the other location is not an BzrLocation' do
        allow(other).to receive(:is_a?).and_return(false)
        expect(subject).to_not eq(other)
      end

      it 'returns false when the uri is different' do
        allow(other).to receive(:uri).and_return('different')
        expect(subject).to_not eq(other)
      end

      it 'returns false when the ref is different' do
        allow(other).to receive(:ref).and_return('different')
        expect(subject).to_not eq(other)
      end
    end

    describe '#to_s' do
      it 'gives the ref' do
        expect(subject.to_s).to eq('https://repo.com (at ref: revno:2)')
      end
    end

    describe '#to_lock' do
      it 'includes all the information' do
        expect(subject.to_lock).to eq <<-EOH.gsub(/^ {8}/, '')
            bzr: https://repo.com
            revision: revid:test@test.net-20140320213448-r0103d8bgjlu5jyz
            ref: revno:2
        EOH
      end
    end

    describe '#bzr' do
      before { described_class.send(:public, :bzr) }

      it 'raises an error if Bazaar is not installed' do
        allow(Berkshelf).to receive(:which).and_return(false)
        expect { subject.bzr('foo') }.to raise_error(BzrLocation::BzrNotInstalled)
      end

      it 'raises an error if the command fails' do
        allow(Berkshelf).to receive(:which).and_return(true)
        shell_out = double('shell_out', success?: false, stdout: 'bzr: ERROR: Not a branch: "foo".', stderr: nil)
        allow(Buff::ShellOut).to receive(:shell_out).and_return(shell_out)
        expect { subject.bzr('foo') }.to raise_error(BzrLocation::BzrCommandError)
      end
    end
  end
end
