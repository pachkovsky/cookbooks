include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping deploy::rails application #{application} as it is not a Rails app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  before_migrate do
    node[:deploy].each do |application, deploy|
      Chef::Log.info('Creating .env')
      file "#{release_path}/.env" do
        owner deploy[:user]
        group deploy[:group]
        mode '0660'
        content OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables]).map{|key, value| "#{key}=#{value}"}.join("\n")
        action :create
      end
    end
  end
end