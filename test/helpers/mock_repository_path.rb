class ActiveSupport::TestCase
  # Mocks the on-disk repository path to point to the fixture repository.
  def mock_repository_path(repo)
    fixture_repo_path = Rails.root.join('test', 'fixtures', 'repo.git').to_s
    grit_repo = Grit::Repo.new fixture_repo_path
    repo.stubs(:grit_repo).returns(grit_repo)
  end
  
  # Mocks Grit so all repositories point to the fixtures repository.
  def mock_any_repository_path
    fixture_repo_path = Rails.root.join('test', 'fixtures', 'repo.git').to_s
    grit_repo = Grit::Repo.new fixture_repo_path
    Grit::Repo.stubs(:new).returns(grit_repo)
  end    
end
