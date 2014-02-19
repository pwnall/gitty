class ActiveSupport::TestCase
  # Mocks the on-disk repository path to point to the fixture repository.
  def mock_repository_path(repo)
    fixture_repo_path = Rails.root.join('test', 'fixtures', 'repo.git').to_s
    repo.stubs(:local_path).returns fixture_repo_path
    rugged_repo = Rugged::Repository.new fixture_repo_path
    repo.stubs(:rugged_repository).returns rugged_repo
  end

  # Mocks Grit so all repositories point to the fixtures repository.
  def mock_any_repository_path
    fixture_repo_path = Rails.root.join('test', 'fixtures', 'repo.git').to_s
    Repository.any_instance.stubs(:local_path).returns fixture_repo_path
    rugged_repo = Rugged::Repo.new fixture_repo_path
    Rugged::Repo.stubs(:new).returns(rugged_repo)
  end
end
