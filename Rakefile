task :default do
  if ENV['TRAVIS_CI']
    sh 'xvfb-run rspec spec'
  else
    sh 'rspec spec'
  end
end

desc "Prepare archive for deployment"
task :archive do
  sh 'zip -r ~/dsf.zip autoload/ doc/dsf.txt plugin/'
end
