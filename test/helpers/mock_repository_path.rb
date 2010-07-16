class ActiveSupport::TestCase
  # Mock the on-disk repository path to point to the fixture repository.
  def mock_repository_path(repo)
    fixture_repo_path = Rails.root.join('test', 'fixtures', 'repo.git').to_s
    grit_repo = Grit::Repo.new fixture_repo_path
    flexmock(repo).should_receive(:grit_repo).and_return(grit_repo)
  end    
end
