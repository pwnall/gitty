#!/bin/bash
#
# Builds the test repository in repo.git.

# Need a bare repository, because that's what Gitty manages.
rm -rf repo.git
mkdir -p repo.git
cd repo.git
git init --bare
cd ..

# Now we need a real repository to test off.
rm -r repo_temp
git clone ./repo.git repo_temp
cd repo_temp
git config user.name "Dexter"
git config user.email "dexter@gmail.com"

# Commit 1: lib/ghost/hello.rb and lib/markdpwn submodule
mkdir -p lib
mkdir -p lib/ghost
echo "STDOUT.puts [:Hello, :World].join(' ')" > lib/ghost/hello.rb
git submodule add git://github.com/pwnall/markdpwn.git lib/markdpwn
cd lib/markdpwn
git checkout 50dd97ed5108082b0d0c69512ae71b2af9330857
cd ../..
git add .
GIT_COMMITTER_DATE="Thu Apr 2 13:14:16 2012 -0400" git commit \
    -m "Hello world" --author="Victor Costan <victor@costan.us>" \
    --date="Thu Apr 2 13:14:15 2012 -0400"
GIT_COMMITTER_DATE="Thu Apr 2 13:15:16 2012 -0400" git tag \
    --annotate -m "Released version 1." v1.0

# Commit 2: lib/ghost.rb
git checkout -b branch1
echo "require 'ghost/hello.rb'" > lib/ghost.rb
git add .
GIT_COMMITTER_DATE="Thu Apr 2 14:15:17 2012 -0400" git commit -m "Master require" --author="Dexter <dexter@gmail.com>" --date="Thu Apr 2 14:15:16 2012 -0400"
GIT_COMMITTER_DATE="Thu Apr 2 14:16:17 2012 -0400" git tag --annotate -m "Unicorns private build." unicorns

# Commit 3: lib/easy.rb, lib/ghost/easy.rb
# Updates module lib/markdpwn, adds module lib/vendored_gitty
git checkout master
git checkout -b branch2
echo "Dir['ghost/**/*.rb'].each { |f| require f }" > lib/easy.rb
echo "require 'ghost/hello.rb'" > lib/ghost/easy.rb
cd lib/markdpwn
git checkout ecfce28e87c21965a8fadd65b0e12ea9ac2d2937
cd ../..
git submodule add git://github.com/pwnall/gitty.git lib/vendored_gitty
cd lib/vendored_gitty
git checkout 796087fe7706929726f7163e9b39369cc8ea3053
cd ../..
git add .
GIT_COMMITTER_DATE="Thu Apr 2 16:17:19 2012 -0400" git commit -m "Easy mode" --author="Victor Costan <victor@costan.us>" --date="Thu Apr 2 16:17:18 2012 -0400"
GIT_COMMITTER_DATE="Thu Apr 2 16:18:19 2012 -0400" git tag --annotate -m "Demo private build." demo

# Commit 4: merge commits 1 and 2
git checkout master
git merge branch2
git merge branch1 --no-commit
GIT_COMMITTER_DATE="Thu Apr 3 21:21:22 2012 -0400" git commit -m "Merge branch 'branch1'" --author="Dexter <dexter@gmail.com>" --date="Thu Apr 3 21:21:21 2012 -0400"
GIT_COMMITTER_DATE="Thu Apr 3 22:22:22 2012 -0400" git tag --annotate -m "Released version 2." v2.0

# Push to gitty and clean up.
git push --all
git push --tags
cd ..
rm -rf repo_temp
