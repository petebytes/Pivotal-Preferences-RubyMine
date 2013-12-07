require "mine_prefs/commands/backups/backup"
require "mine_prefs/commands/backups/file"

module MinePrefs
  module Commands
    module Backups
      describe Backup do
        describe "#undo" do
          context "backup files exist" do
            it "copies the backup files over" do
              installation_bundle = [double(:file, target: "/target/file")]
              filesystem = double :filesystem

              filesystem.should_receive(:mv).with("/target/file.bak", "/target/file")

              Backup.new(filesystem: filesystem).undo(installation_bundle)
            end
          end

          context "backup files do not exist" do
            it "silently passes over them" do
              installation_bundle = [double(:file, target: "/target/file")]
              filesystem = double :filesystem

              filesystem.stub(:mv).with("/target/file.bak", "/target/file").and_raise Errno::ENOENT

              expect {
                Backup.new(filesystem: filesystem).undo(installation_bundle)
              }.to_not raise_exception
            end
          end
        end

        describe "#execute" do
          context "file to be replaced by installation does not already exist in target" do
            it "should silently ignore it" do
              installation = [double(:file, target: "/bar/foo")]
              filesystem = double :filesystem

              filesystem.stub(:mv).with("/bar/foo", "/bar/foo.bak", force: true).and_raise Errno::ENOENT

              expect {
                Backup.new(filesystem: filesystem).execute(installation)
              }.not_to raise_exception
            end
          end

          context "target file exists" do
            it "backs up all files that will be replaced by the installation" do
              installation = [double(:file, target: "/bar/foo")]
              filesystem = double :filesystem

              filesystem.should_receive(:mv).with("/bar/foo", "/bar/foo.bak", force: true)

              Backup.new(filesystem: filesystem).execute(installation)
            end
          end

          context "execute file already exists" do
            it "backs up the target file anyways, overwriting the original execute file" do
              installation = [double(:file, target: "/bar/foo")]

              filesystem = double :filesystem

              filesystem.should_receive(:mv).with("/bar/foo", "/bar/foo.bak", force: true)

              Backup.new(filesystem: filesystem).execute(installation)
            end
          end
        end
      end
    end
  end
end
