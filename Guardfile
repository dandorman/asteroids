group 'backend' do
  guard 'bundler' do
    watch('Gemfile')
  end
end

group 'frontend' do
  guard 'coffeescript', :output => 'app/javascripts/compiled' do
    watch(%r<^app/(.*)\.coffee$>)
  end

  # guard 'coffeescript', :output => 'spec/compiled' do
  #   watch(%r<^spec/(.*)\.coffee$>)
  # end

  guard 'jasmine-headless-webkit' do
    watch(%r<^spec/.+\.coffee$>)
    watch(%r<^app/.+\.coffee$>)
  end

  # guard 'jasmine-headless-webkit' do
  #   watch(%r<^spec/compiled/.+\.js$>)
  #   watch(%r<^app/compiled/.+\.js$>)
  # end
end
