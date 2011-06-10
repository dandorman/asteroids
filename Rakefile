desc "Setup the local environment"
task :setup do
  sh %Q!gem install bundler --no-ri --no-rdoc! unless %x[gem list] =~ /bundler/
  sh %Q!bundle install!

  puts "Download and install QT: http://get.qt.nokia.com/qt/source/qt-mac-opensource-4.7.3.dmg"

  sh %Q!mkdir -p log!
  puts "Done!\n\n"
end

desc "Start Express server"
task :server do
  %x{node app.js}
end

desc "Bundle exec guard"
task :guard do
  sh "bundle exec guard"
end

desc "Open a screen session"
task :screen do
  exec <<-CMD
    if [ $(screen -ls | grep Detached | wc -l) -gt 0 ]; then
      echo "Attaching to existing Screen"
      sleep 1.0
      screen -x -c screenrc
    else
      echo "Starting new Screen session"
      sleep 1.0
      screen -c screenrc
    fi
  CMD
end
