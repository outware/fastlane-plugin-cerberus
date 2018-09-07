describe Fastlane::Actions::CerberusAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The cerberus plugin is working!")

      Fastlane::Actions::CerberusAction.run(nil)
    end
  end
end
