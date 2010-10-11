require 'test_helper'

class CommitDiffTest < ActiveSupport::TestCase
  setup do
    @diff = CommitDiff.new :commit => commits(:commit1), 
        :old_path => '/d1/d2/a', :new_path => '/d1/b',
        :old_blob => blobs(:d1_d2_a), :new_blob => blobs(:d1_b)
  end
  
  test 'setup' do
    assert @diff.valid?
  end
  
  test 'commit must be set' do
    @diff.commit = nil
    assert !@diff.valid?
  end
  
  test 'old_blob can be nil iff old_path is nil' do
    @diff.old_blob = nil
    assert !@diff.valid?
    
    @diff.old_path = nil
    @diff.save!
    assert @diff.valid?
  end
    
  test 'new_blob can be nil iff new_path is nil' do
    @diff.new_blob = nil
    assert !@diff.valid?

    @diff.new_path = nil
    assert @diff.valid?
  end

  test 'old_path must be unique within a commit' do
    diff = @diff.commit.diffs.first
    diff.update_attributes! :old_path => @diff.old_path,
                            :old_blob => @diff.old_blob
    assert !@diff.valid?
  end
  
  test 'new_path must be unique within a commit' do
    @diff.new_path = @diff.commit.diffs.first.new_path
    assert !@diff.valid?
  end
  
  test 'new_path can match old_path' do
    @diff.new_path = @diff.old_path
  end
end
