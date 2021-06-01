describe Fastlane::Actions::PgyerClAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The pgyer_cl plugin is working!")

      Fastlane::Actions::PgyerClAction.run({
                                               update_description: "测试",
                                               fs_access_token: "c6659c4f-3e2f-4ab8-ac8e-a8190e217927",
                                               environment: 'dev'
                                           })
    end
  end
end
