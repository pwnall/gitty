require 'test_helper'

class SubmoduleTest < ActiveSupport::TestCase
  setup do
    @repo = submodules(:markdpwn_012).repository
    @submodule = Submodule.new :name => 'vendored_gitty',
                     :gitid => '796087fe7706929726f7163e9b39369cc8ea3053',
                     :repository => @repo
  end
  
  test 'setup' do
    assert @submodule.valid?
  end
  
  test 'repository must be set' do
    @submodule.repository = nil
    assert !@submodule.valid?
  end

  test 'name must be set' do
    @submodule.name = nil
    assert !@submodule.valid?
  end

  test 'gitid must be set' do
    @submodule.gitid = nil
    assert !@submodule.valid?
  end

  test 'no duplicate (gitid, name) pairs' do
    @submodule.name = submodules(:markdpwn_012).name
    assert @submodule.valid?

    @submodule.gitid = submodules(:markdpwn_012).gitid
    assert !@submodule.valid?
  end
  
  test 'from_git_submodule' do
    mock_repository_path @repo
    git_submodule = @repo.grit_repo.
        tree('55c232282ca3c345768919e41e8217c946fca152').contents.
        find { |e| e.name == 'vendored_gitty' }
    submodule = Submodule.from_git_submodule git_submodule, @repo
    assert submodule.valid?, 'Invalid submodule created from git'
    assert_equal @submodule.name, submodule.name
    assert_equal @submodule.gitid, submodule.gitid
    submodule.save!
    assert !@submodule.valid?, "Submodule incorrectly created from git"
  end

  test 'data' do
    submodule = submodules(:markdpwn_012)
    mock_repository_path submodule.repository
    assert_equal "Subproject commit 50dd97ed5108082b0d0c69512ae71b2af9330857\n",
                 submodule.data
    assert_raise TypeError, RuntimeError, 'data are frozen' do
      submodule.data[1] = 'E'
    end
    
    assert_equal ['Subproject commit 50dd97ed5108082b0d0c69512ae71b2af9330857'],
                 submodule.data_lines
    assert_raise TypeError, RuntimeError, 'data_lines array are frozen' do
      submodule.data_lines[0] = 'Subproject no commit'
    end
    assert_raise TypeError, RuntimeError, 'data_lines elements are frozen' do
      submodule.data_lines[0][1] = 'E'
    end
    
    assert_equal 1, submodule.data_line_count, 'data_line_count'
  end
end
