cd ..
aws s3 cp s3://us-east-1-pub-devops-talend-com/puppet/talend-cloud-installer-hiera/ami/extra-us-east-1.yaml packer/extra.yaml

bundle install --path=vendor/bundler --without=development system_tests test
bundle exec librarian-puppet install --clean --verbose --path=modules