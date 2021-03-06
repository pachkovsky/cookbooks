service 'monit' do
  supports status: false, restart: true, reload: true
  action :nothing
end

node[:deploy].each do |application, deploy|
  template "#{node[:monit][:conf_dir]}/sidekiq.monitrc" do
    source 'sidekiq.monitrc.erb'
    mode 0644
    variables(
      deploy: deploy,
      application: application
    )
    notifies :restart, "service[monit]", :immediately
  end

  execute "restart Server" do
    command "sudo monit restart -g sidekiq_#{application}_group"
    action :run
  end
end

